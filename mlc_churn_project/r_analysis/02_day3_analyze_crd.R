# =========================================================
# Ngay 3 - Phan tich ket qua thi nghiem CRD trong RStudio
# Day 3 chi lam CRD:
# - Doc ket qua tu Python
# - Mo ta thong ke
# - Levene test
# - lm() va ANOVA
# - TukeyHSD()
# - Ve boxplot va mean CI
# Khong lam CRFD, interaction plot, hay max_depth = 3/5 o day.
# =========================================================

cat("===== BAT DAU PHAN TICH CRD - DAY 3 =====\n")

# ---------------------------------------------------------
# Kiem tra package can thiet
# ---------------------------------------------------------
required_packages <- c("car", "ggplot2", "dplyr")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Ban chua cai cac package sau: ",
      paste(missing_packages, collapse = ", "),
      ".\nHay chay trong RStudio:\n",
      paste(sprintf("install.packages(\"%s\")", missing_packages), collapse = "\n")
    )
  )
}

library(car)
library(ggplot2)
library(dplyr)

# Tao thu muc output neu chua ton tai
output_dir <- file.path("outputs", "tables")
figure_dir <- "figures"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Doc du lieu ket qua
# ---------------------------------------------------------
cat("Thu muc lam viec hien tai:\n")
print(getwd())

results_path <- file.path("results", "crd_results.csv")

if (!file.exists(results_path)) {
  stop(
    paste0(
      "Khong tim thay file ket qua tai: ", results_path, "\n",
      "Hay kiem tra getwd() trong RStudio va dam bao ban da chay Python truoc:\n",
      "python python/02_day3_run_crd_experiment.py"
    )
  )
}

crd <- read.csv(results_path, stringsAsFactors = FALSE)

cat("\n[1] dim(crd):\n")
print(dim(crd))

cat("\n[2] head(crd):\n")
print(head(crd))

cat("\n[3] str(crd):\n")
str(crd)

cat("\n[4] table(crd$k) truoc khi doi factor:\n")
print(table(crd$k))

crd$k <- as.factor(crd$k)


# ---------------------------------------------------------
# 2. Tinh thong ke mo ta
# ---------------------------------------------------------
cat("\n===== THONG KE MO TA THEO k =====\n")

crd_summary_by_k <- crd %>%
  group_by(k) %>%
  summarise(
    n = n(),
    mean = mean(f1),
    sd = sd(f1),
    se = sd / sqrt(n),
    ci_half_width = qt(0.975, df = n - 1) * se,
    ci_lower = mean - ci_half_width,
    ci_upper = mean + ci_half_width,
    .groups = "drop"
  ) %>%
  select(k, n, mean, sd, se, ci_lower, ci_upper)

print(crd_summary_by_k)

write.csv(
  crd_summary_by_k,
  file.path(output_dir, "crd_summary_by_k.csv"),
  row.names = FALSE
)


# ---------------------------------------------------------
# 3. Kiem tra phuong sai bang Levene Test
# ---------------------------------------------------------
cat("\n===== LEVENE TEST =====\n")
levene_result <- leveneTest(f1 ~ k, data = crd)
print(levene_result)

cat(
  "\nGoi y cach doc Levene test:\n",
  "- Neu p-value < 0.05: phuong sai F1 giua cac nhom k khac nhau co y nghia thong ke.\n",
  "- Neu p-value >= 0.05: chua co bang chung cho thay phuong sai F1 giua cac nhom k khac nhau.\n",
  sep = ""
)


# ---------------------------------------------------------
# 4. Danh gia anh huong cua k bang lm() va ANOVA
# ---------------------------------------------------------
cat("\n===== lm() va ANOVA =====\n")
model_crd <- lm(f1 ~ k, data = crd)

cat("summary(model_crd):\n")
print(summary(model_crd))

cat("\nanova(model_crd):\n")
anova_result <- anova(model_crd)
print(anova_result)

cat(
  "\nGoi y cach doc ANOVA:\n",
  "- Neu p-value cua k < 0.05 thi k co anh huong co y nghia thong ke den F1.\n",
  "- Neu p-value cua k >= 0.05 thi chua co bang chung k anh huong den F1.\n",
  sep = ""
)


# ---------------------------------------------------------
# 5. So sanh cap bang TukeyHSD
# ---------------------------------------------------------
cat("\n===== TUKEY HSD =====\n")
aov_crd <- aov(f1 ~ k, data = crd)
tukey_crd <- TukeyHSD(aov_crd)
print(tukey_crd)

tukey_df <- as.data.frame(tukey_crd$k)
tukey_df$comparison <- rownames(tukey_df)
rownames(tukey_df) <- NULL
tukey_df <- tukey_df[, c("comparison", "diff", "lwr", "upr", "p adj")]

write.csv(
  tukey_df,
  file.path(output_dir, "crd_tukey_results.csv"),
  row.names = FALSE
)

cat(
  "\nGoi y cach doc TukeyHSD:\n",
  "- Neu p adj < 0.05 thi hai muc k khac biet co y nghia thong ke.\n",
  "- Neu p adj >= 0.05 thi chua co bang chung hai muc k khac biet.\n",
  sep = ""
)


# ---------------------------------------------------------
# 6. Ve bieu do
# ---------------------------------------------------------
cat("\n===== VE BIEU DO =====\n")

boxplot_path <- file.path(figure_dir, "crd_boxplot.png")
mean_ci_path <- file.path(figure_dir, "crd_mean_ci.png")

p_boxplot <- ggplot(crd, aes(x = k, y = f1, fill = k)) +
  geom_boxplot(alpha = 0.8, outlier.color = "red") +
  labs(
    title = "Boxplot F1-score theo so fold k",
    x = "So fold k",
    y = "F1-score"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(
  filename = boxplot_path,
  plot = p_boxplot,
  width = 8,
  height = 5,
  dpi = 300
)

p_mean_ci <- ggplot(crd_summary_by_k, aes(x = k, y = mean, group = 1)) +
  geom_line(color = "#2C7FB8", linewidth = 0.8) +
  geom_point(color = "#2C7FB8", size = 3) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.15, color = "#D95F0E") +
  labs(
    title = "Mean F1-score va khoang tin cay 95% theo k",
    x = "So fold k",
    y = "Mean F1-score"
  ) +
  theme_minimal()

ggsave(
  filename = mean_ci_path,
  plot = p_mean_ci,
  width = 8,
  height = 5,
  dpi = 300
)

cat("Da luu boxplot tai:\n")
print(boxplot_path)
cat("Da luu bieu do mean CI tai:\n")
print(mean_ci_path)


# ---------------------------------------------------------
# 7. In phan nhac gui output
# ---------------------------------------------------------
cat("\n===== NHAC GUI OUTPUT CHO TRO LY =====\n")
cat(
  "Sau khi chay xong, hay gui lai cac ket qua sau:\n",
  "1. Bang crd_summary_by_k.\n",
  "2. Ket qua leveneTest().\n",
  "3. Ket qua anova(model_crd).\n",
  "4. Ket qua TukeyHSD.\n",
  "5. Thong tin hai bieu do da luu (hoac mo ta ngan / anh chup neu can).\n",
  sep = ""
)

cat("\n===== KET THUC PHAN TICH CRD - DAY 3 =====\n")
