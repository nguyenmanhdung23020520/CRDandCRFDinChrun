# =========================================================
# Ngay 4 - Phan tich ket qua thi nghiem CRFD trong RStudio
# Day 4 chi lam CRFD:
# - Doc ket qua tu Python
# - Mo ta thong ke theo k va max_depth
# - lm() va ANOVA cho hai yeu to va tuong tac
# - TukeyHSD()
# - Ve interaction plot va bieu do so sanh
# Khong lam lai CRD hay baseline o day.
# =========================================================

cat("===== BAT DAU PHAN TICH CRFD - DAY 4 =====\n")

# ---------------------------------------------------------
# Kiem tra package can thiet
# ---------------------------------------------------------
required_packages <- c("ggplot2", "dplyr")
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

results_path <- file.path("results", "crfd_results.csv")

if (!file.exists(results_path)) {
  stop(
    paste0(
      "Khong tim thay file ket qua tai: ", results_path, "\n",
      "Hay kiem tra getwd() trong RStudio va dam bao ban da chay Python truoc:\n",
      "python python/03_day4_run_crfd_experiment.py"
    )
  )
}

crfd <- read.csv(results_path, stringsAsFactors = FALSE, check.names = FALSE)

cat("\n[1] dim(crfd):\n")
print(dim(crfd))

cat("\n[2] head(crfd):\n")
print(head(crfd))

cat("\n[3] str(crfd):\n")
str(crfd)

cat("\n[4] table(crfd$k):\n")
print(table(crfd$k))

cat("\n[5] table(crfd$max_depth):\n")
print(table(crfd$max_depth))

cat("\n[6] table(crfd$k, crfd$max_depth):\n")
print(table(crfd$k, crfd$max_depth))

crfd$k <- as.factor(crfd$k)
crfd$max_depth <- as.factor(crfd$max_depth)
crfd$max_depth <- factor(crfd$max_depth, levels = c("3", "5", "None"))


# ---------------------------------------------------------
# 2. Tinh thong ke mo ta
# ---------------------------------------------------------
cat("\n===== THONG KE MO TA THEO TO HOP k va max_depth =====\n")

crfd_summary_by_k_depth <- crfd %>%
  group_by(k, max_depth) %>%
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
  select(k, max_depth, n, mean, sd, se, ci_lower, ci_upper)

print(crfd_summary_by_k_depth)

write.csv(
  crfd_summary_by_k_depth,
  file.path(output_dir, "crfd_summary_by_k_depth.csv"),
  row.names = FALSE
)

cat("\n===== THONG KE MO TA THEO max_depth =====\n")
crfd_summary_by_depth <- crfd %>%
  group_by(max_depth) %>%
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
  select(max_depth, n, mean, sd, se, ci_lower, ci_upper)

print(crfd_summary_by_depth)

write.csv(
  crfd_summary_by_depth,
  file.path(output_dir, "crfd_summary_by_depth.csv"),
  row.names = FALSE
)

cat("\n===== THONG KE MO TA THEO k =====\n")
crfd_summary_by_k <- crfd %>%
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

print(crfd_summary_by_k)

write.csv(
  crfd_summary_by_k,
  file.path(output_dir, "crfd_summary_by_k.csv"),
  row.names = FALSE
)


# ---------------------------------------------------------
# 3. Phan tich bang lm() va ANOVA
# ---------------------------------------------------------
cat("\n===== lm() va ANOVA =====\n")
model_crfd <- lm(f1 ~ k * max_depth, data = crfd)

cat("summary(model_crfd):\n")
print(summary(model_crfd))

cat("\nanova(model_crfd):\n")
anova_result <- anova(model_crfd)
print(anova_result)

cat(
  "\nGoi y cach doc ANOVA:\n",
  "- Neu p-value cua k < 0.05 thi k co anh huong co y nghia thong ke den F1.\n",
  "- Neu p-value cua max_depth < 0.05 thi max_depth co anh huong co y nghia thong ke den F1.\n",
  "- Neu p-value cua k:max_depth < 0.05 thi co tuong tac co y nghia thong ke giua k va max_depth.\n",
  "- Neu p-value cua k:max_depth >= 0.05 thi chua co bang chung ve tuong tac.\n",
  sep = ""
)


# ---------------------------------------------------------
# 4. So sanh cap bang TukeyHSD
# ---------------------------------------------------------
cat("\n===== TUKEY HSD =====\n")
aov_crfd <- aov(f1 ~ k * max_depth, data = crfd)
tukey_crfd <- TukeyHSD(aov_crfd)
print(tukey_crfd)

if ("k" %in% names(tukey_crfd)) {
  tukey_k_df <- as.data.frame(tukey_crfd$k)
  tukey_k_df$comparison <- rownames(tukey_k_df)
  rownames(tukey_k_df) <- NULL
  tukey_k_df <- tukey_k_df[, c("comparison", "diff", "lwr", "upr", "p adj")]

  write.csv(
    tukey_k_df,
    file.path(output_dir, "crfd_tukey_k.csv"),
    row.names = FALSE
  )
}

if ("max_depth" %in% names(tukey_crfd)) {
  tukey_depth_df <- as.data.frame(tukey_crfd$max_depth)
  tukey_depth_df$comparison <- rownames(tukey_depth_df)
  rownames(tukey_depth_df) <- NULL
  tukey_depth_df <- tukey_depth_df[, c("comparison", "diff", "lwr", "upr", "p adj")]

  write.csv(
    tukey_depth_df,
    file.path(output_dir, "crfd_tukey_max_depth.csv"),
    row.names = FALSE
  )
}

interaction_name <- "k:max_depth"
if (interaction_name %in% names(tukey_crfd)) {
  tukey_interaction_df <- as.data.frame(tukey_crfd[[interaction_name]])
  tukey_interaction_df$comparison <- rownames(tukey_interaction_df)
  rownames(tukey_interaction_df) <- NULL
  tukey_interaction_df <- tukey_interaction_df[, c("comparison", "diff", "lwr", "upr", "p adj")]

  write.csv(
    tukey_interaction_df,
    file.path(output_dir, "crfd_tukey_interaction.csv"),
    row.names = FALSE
  )
}

cat(
  "\nGoi y cach doc TukeyHSD:\n",
  "- Neu p adj < 0.05 thi hai nhom khac biet co y nghia thong ke.\n",
  "- Neu p adj >= 0.05 thi chua co bang chung hai nhom khac biet.\n",
  sep = ""
)


# ---------------------------------------------------------
# 5. Ve interaction plot va bieu do so sanh
# ---------------------------------------------------------
cat("\n===== VE BIEU DO =====\n")

boxplot_path <- file.path(figure_dir, "crfd_boxplot_by_depth.png")
mean_ci_path <- file.path(figure_dir, "crfd_mean_ci.png")
interaction_path <- file.path(figure_dir, "crfd_interaction_plot.png")

p_boxplot <- ggplot(crfd, aes(x = max_depth, y = f1, fill = max_depth)) +
  geom_boxplot(alpha = 0.8, outlier.color = "red") +
  facet_wrap(~ k) +
  labs(
    title = "Boxplot F1-score theo max_depth, chia theo k",
    x = "max_depth",
    y = "F1-score"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(
  filename = boxplot_path,
  plot = p_boxplot,
  width = 9,
  height = 5,
  dpi = 300
)

p_mean_ci <- ggplot(
  crfd_summary_by_k_depth,
  aes(x = k, y = mean, color = max_depth, group = max_depth)
) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.12) +
  labs(
    title = "Mean F1-score va CI 95% theo to hop k va max_depth",
    x = "So fold k",
    y = "Mean F1-score",
    color = "max_depth"
  ) +
  theme_minimal()

ggsave(
  filename = mean_ci_path,
  plot = p_mean_ci,
  width = 9,
  height = 5,
  dpi = 300
)

p_interaction <- ggplot(
  crfd_summary_by_k_depth,
  aes(x = k, y = mean, color = max_depth, group = max_depth)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.12) +
  labs(
    title = "Interaction plot giua k va max_depth",
    x = "So fold k",
    y = "Mean F1-score",
    color = "max_depth"
  ) +
  theme_minimal()

ggsave(
  filename = interaction_path,
  plot = p_interaction,
  width = 9,
  height = 5,
  dpi = 300
)

cat("Da luu boxplot tai:\n")
print(boxplot_path)
cat("Da luu bieu do mean CI tai:\n")
print(mean_ci_path)
cat("Da luu interaction plot tai:\n")
print(interaction_path)


# ---------------------------------------------------------
# 6. Tim to hop co mean F1 cao nhat
# ---------------------------------------------------------
cat("\n===== TO HOP CO MEAN F1 CAO NHAT =====\n")

best_combination <- crfd_summary_by_k_depth %>%
  arrange(desc(mean), desc(ci_upper)) %>%
  slice(1)

print(best_combination)

cat(
  "\nLuu y: day chi la to hop co mean F1 cao nhat trong ket qua thi nghiem.\n",
  "Khong nen ket luan day chac chan la cau hinh tot nhat neu ANOVA/Tukey chua cho thay y nghia thong ke.\n",
  sep = ""
)


# ---------------------------------------------------------
# 7. In phan nhac gui output
# ---------------------------------------------------------
cat("\n===== NHAC GUI OUTPUT CHO TRO LY =====\n")
cat(
  "Sau khi chay xong, hay gui lai cac ket qua sau:\n",
  "1. Bang crfd_summary_by_k_depth.\n",
  "2. Bang crfd_summary_by_depth.\n",
  "3. Bang crfd_summary_by_k.\n",
  "4. Ket qua anova(model_crfd).\n",
  "5. Ket qua TukeyHSD.\n",
  "6. To hop co mean F1 cao nhat.\n",
  "7. Thong tin cac bieu do da luu.\n",
  sep = ""
)

cat("\n===== KET THUC PHAN TICH CRFD - DAY 4 =====\n")
