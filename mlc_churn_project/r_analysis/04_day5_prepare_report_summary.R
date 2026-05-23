# =========================================================
# Ngay 5 - Tong hop ket qua va chuan bi bao cao
# Muc tieu:
# - Kiem tra file ket qua va hinh anh da day du chua
# - Doc cac bang summary neu co
# - Tao bang tong hop cuoi
# - In checklist phan con thieu de hoan thien bao cao
# Luu y: Khong chay them mo hinh hay thi nghiem moi trong Day 5
# =========================================================

cat("===== BAT DAU TONG HOP DAY 5 =====\n")

cat("Thu muc lam viec hien tai:\n")
print(getwd())

output_dir <- file.path("outputs", "tables")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

safe_read_csv <- function(path, label) {
  if (!file.exists(path)) {
    warning(paste0("Khong tim thay file: ", path, " (", label, ")"))
    return(NULL)
  }

  tryCatch(
    read.csv(path, stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) {
      warning(paste0("Doc file that bai: ", path, " (", label, "). Loi: ", e$message))
      NULL
    }
  )
}

check_items <- function(items_df, item_type) {
  items_df$exists <- file.exists(items_df$path)

  cat("\n===== KIEM TRA ", toupper(item_type), " =====\n", sep = "")
  print(items_df[, c("label", "path", "day", "exists")], row.names = FALSE)

  missing_df <- items_df[!items_df$exists, , drop = FALSE]

  if (nrow(missing_df) > 0) {
    cat("\nCac ", item_type, " dang thieu:\n", sep = "")
    for (i in seq_len(nrow(missing_df))) {
      cat(
        "- ", missing_df$label[i],
        " | Day ", missing_df$day[i],
        " | Can chay lai: ", missing_df$rerun_script[i],
        " | Duong dan mong doi: ", missing_df$path[i], "\n",
        sep = ""
      )
    }
  } else {
    cat("Tat ca ", item_type, " yeu cau deu da ton tai.\n", sep = "")
  }

  items_df
}

# ---------------------------------------------------------
# 1. Kiem tra file ket qua va hinh anh
# ---------------------------------------------------------
required_result_files <- data.frame(
  label = c(
    "CRD raw results",
    "CRFD raw results",
    "Baseline summary",
    "CRD summary by k",
    "CRFD summary by k_depth",
    "CRFD summary by depth",
    "CRFD summary by k"
  ),
  path = c(
    file.path("results", "crd_results.csv"),
    file.path("results", "crfd_results.csv"),
    file.path("outputs", "tables", "baseline_result.csv"),
    file.path("outputs", "tables", "crd_summary_by_k.csv"),
    file.path("outputs", "tables", "crfd_summary_by_k_depth.csv"),
    file.path("outputs", "tables", "crfd_summary_by_depth.csv"),
    file.path("outputs", "tables", "crfd_summary_by_k.csv")
  ),
  day = c("Day 3", "Day 4", "Day 2", "Day 3", "Day 4", "Day 4", "Day 4"),
  rerun_script = c(
    "python/02_day3_run_crd_experiment.py",
    "python/03_day4_run_crfd_experiment.py",
    "python/01_day2_rf_baseline.py",
    "r_analysis/02_day3_analyze_crd.R",
    "r_analysis/03_day4_analyze_crfd.R",
    "r_analysis/03_day4_analyze_crfd.R",
    "r_analysis/03_day4_analyze_crfd.R"
  ),
  stringsAsFactors = FALSE
)

required_figures <- data.frame(
  label = c(
    "CRD boxplot",
    "CRD mean CI plot",
    "CRFD boxplot by depth",
    "CRFD mean CI plot",
    "CRFD interaction plot"
  ),
  path = c(
    file.path("figures", "crd_boxplot.png"),
    file.path("figures", "crd_mean_ci.png"),
    file.path("figures", "crfd_boxplot_by_depth.png"),
    file.path("figures", "crfd_mean_ci.png"),
    file.path("figures", "crfd_interaction_plot.png")
  ),
  day = c("Day 3", "Day 3", "Day 4", "Day 4", "Day 4"),
  rerun_script = c(
    "r_analysis/02_day3_analyze_crd.R",
    "r_analysis/02_day3_analyze_crd.R",
    "r_analysis/03_day4_analyze_crfd.R",
    "r_analysis/03_day4_analyze_crfd.R",
    "r_analysis/03_day4_analyze_crfd.R"
  ),
  stringsAsFactors = FALSE
)

result_status <- check_items(required_result_files, "file ket qua")
figure_status <- check_items(required_figures, "hinh anh")

# ---------------------------------------------------------
# 2. Doc cac bang summary neu co
# ---------------------------------------------------------
data_df <- safe_read_csv(file.path("data", "mlc_churn.csv"), "du lieu goc")
baseline_df <- safe_read_csv(file.path("outputs", "tables", "baseline_result.csv"), "baseline")
crd_summary_df <- safe_read_csv(file.path("outputs", "tables", "crd_summary_by_k.csv"), "CRD summary")
crfd_summary_k_depth_df <- safe_read_csv(file.path("outputs", "tables", "crfd_summary_by_k_depth.csv"), "CRFD summary by k_depth")
crfd_summary_depth_df <- safe_read_csv(file.path("outputs", "tables", "crfd_summary_by_depth.csv"), "CRFD summary by depth")
crfd_summary_k_df <- safe_read_csv(file.path("outputs", "tables", "crfd_summary_by_k.csv"), "CRFD summary by k")

cat("\n===== CAC BANG SUMMARY DOC DUOC =====\n")

if (!is.null(baseline_df)) {
  cat("\nBaseline summary:\n")
  print(baseline_df)
}

if (!is.null(crd_summary_df)) {
  cat("\nCRD summary by k:\n")
  print(crd_summary_df)
}

if (!is.null(crfd_summary_k_depth_df)) {
  cat("\nCRFD summary by k_depth:\n")
  print(crfd_summary_k_depth_df)
}

if (!is.null(crfd_summary_depth_df)) {
  cat("\nCRFD summary by depth:\n")
  print(crfd_summary_depth_df)
}

if (!is.null(crfd_summary_k_df)) {
  cat("\nCRFD summary by k:\n")
  print(crfd_summary_k_df)
}

# ---------------------------------------------------------
# 3. Tao bang tong hop ngan
# ---------------------------------------------------------
dataset_rows <- NA_integer_
dataset_columns <- NA_integer_
churn_yes_ratio <- NA_real_

if (!is.null(data_df)) {
  dataset_rows <- nrow(data_df)
  dataset_columns <- ncol(data_df)

  if ("churn" %in% names(data_df)) {
    churn_values <- trimws(tolower(as.character(data_df$churn)))
    churn_yes_ratio <- mean(churn_values == "yes", na.rm = TRUE)
  }
}

baseline_f1 <- NA_real_
if (!is.null(baseline_df) && "f1_positive_yes" %in% names(baseline_df) && nrow(baseline_df) >= 1) {
  baseline_f1 <- baseline_df$f1_positive_yes[1]
}

dropped_features_text <- paste(
  c(
    "total_day_charge",
    "total_eve_charge",
    "total_night_charge",
    "total_intl_charge"
  ),
  collapse = ", "
)

final_summary_day5 <- data.frame(
  dataset_rows = dataset_rows,
  dataset_columns = dataset_columns,
  target = "churn",
  positive_class = "yes",
  churn_yes_ratio = churn_yes_ratio,
  dropped_features = dropped_features_text,
  baseline_f1 = baseline_f1,
  crd_result_file = ifelse(file.exists(file.path("results", "crd_results.csv")), "available", "missing"),
  crfd_result_file = ifelse(file.exists(file.path("results", "crfd_results.csv")), "available", "missing"),
  stringsAsFactors = FALSE
)

cat("\n===== FINAL SUMMARY DAY 5 =====\n")
print(final_summary_day5)

write.csv(
  final_summary_day5,
  file.path(output_dir, "final_summary_day5.csv"),
  row.names = FALSE
)

cat("\nDa luu bang tong hop tai:\n")
print(file.path(output_dir, "final_summary_day5.csv"))

# ---------------------------------------------------------
# 4. In checklist phan con thieu
# ---------------------------------------------------------
tukey_crd_exists <- file.exists(file.path("outputs", "tables", "crd_tukey_results.csv"))
tukey_crfd_exists <- all(
  file.exists(file.path("outputs", "tables", "crfd_tukey_k.csv")),
  file.exists(file.path("outputs", "tables", "crfd_tukey_max_depth.csv")),
  file.exists(file.path("outputs", "tables", "crfd_tukey_interaction.csv"))
)

checklist_df <- data.frame(
  item = c(
    "Da co crd_results.csv chua?",
    "Da co crfd_results.csv chua?",
    "Da co crd_summary_by_k.csv chua?",
    "Da co crfd_summary_by_k_depth.csv chua?",
    "Da co bieu do CRD chua?",
    "Da co bieu do CRFD chua?",
    "Da co p-value Levene chua?",
    "Da co p-value ANOVA CRD chua?",
    "Da co p-value ANOVA CRFD chua?",
    "Da co TukeyHSD chua?"
  ),
  status = c(
    ifelse(file.exists(file.path("results", "crd_results.csv")), "YES", "NO"),
    ifelse(file.exists(file.path("results", "crfd_results.csv")), "YES", "NO"),
    ifelse(file.exists(file.path("outputs", "tables", "crd_summary_by_k.csv")), "YES", "NO"),
    ifelse(file.exists(file.path("outputs", "tables", "crfd_summary_by_k_depth.csv")), "YES", "NO"),
    ifelse(
      all(
        file.exists(file.path("figures", "crd_boxplot.png")),
        file.exists(file.path("figures", "crd_mean_ci.png"))
      ),
      "YES",
      "NO"
    ),
    ifelse(
      all(
        file.exists(file.path("figures", "crfd_boxplot_by_depth.png")),
        file.exists(file.path("figures", "crfd_mean_ci.png")),
        file.exists(file.path("figures", "crfd_interaction_plot.png"))
      ),
      "YES",
      "NO"
    ),
    "CAN_XAC_NHAN_TU_CONSOLE_R",
    "CAN_XAC_NHAN_TU_CONSOLE_R",
    "CAN_XAC_NHAN_TU_CONSOLE_R",
    ifelse(tukey_crd_exists || tukey_crfd_exists, "YES", "NO")
  ),
  action_if_missing = c(
    "Chay python/02_day3_run_crd_experiment.py",
    "Chay python/03_day4_run_crfd_experiment.py",
    "Chay r_analysis/02_day3_analyze_crd.R",
    "Chay r_analysis/03_day4_analyze_crfd.R",
    "Chay r_analysis/02_day3_analyze_crd.R",
    "Chay r_analysis/03_day4_analyze_crfd.R",
    "Neu chua luu/ghi lai, chay lai source('r_analysis/02_day3_analyze_crd.R') va copy output leveneTest()",
    "Neu chua luu/ghi lai, chay lai source('r_analysis/02_day3_analyze_crd.R') va copy output anova(model_crd)",
    "Neu chua luu/ghi lai, chay lai source('r_analysis/03_day4_analyze_crfd.R') va copy output anova(model_crfd)",
    "Neu thieu CSV Tukey, chay lai script R Day 3 hoac Day 4 tuong ung"
  ),
  stringsAsFactors = FALSE
)

cat("\n===== CHECKLIST PHAN CON THIEU =====\n")
print(checklist_df, row.names = FALSE)

cat("\nLuu y:\n")
cat("- Cac muc p-value Levene/ANOVA thuong chi hien trong console cua RStudio neu chua co file luu rieng.\n")
cat("- Day 5 khong chay them mo hinh hay thi nghiem moi; chi tong hop ket qua da co.\n")
cat("===== KET THUC TONG HOP DAY 5 =====\n")
