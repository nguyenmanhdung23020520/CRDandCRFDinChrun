# =========================================================
# Ngay 2 - EDA va de xuat chon bien cho bai toan churn
# Su dung trong RStudio theo huong hybrid:
# - R: phan tich du lieu, missing value, churn, tuong quan, goi y chon bien
# - Khong lam CRD / CRFD / repeated k-fold / Levene / Tukey / interaction plot
# =========================================================

cat("===== BAT DAU PHAN TICH NGAY 2 BANG R =====\n")

# Tao thu muc output neu chua ton tai
output_dir <- file.path("outputs", "tables")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Kiem tra thu muc lam viec
cat("Thu muc lam viec hien tai:\n")
print(getwd())

# ---------------------------------------------------------
# 1. Doc du lieu
# ---------------------------------------------------------
data_path <- file.path("data", "mlc_churn.csv")

if (!file.exists(data_path)) {
  stop(
    paste0(
      "Khong tim thay file du lieu tai: ", data_path, "\n",
      "Hay kiem tra getwd() trong RStudio.\n",
      "Neu can, dat working directory ve thu muc goc cua project mlc_churn_project,\n",
      "sau do chay lai: source('r_analysis/01_day2_eda_feature_selection.R')"
    )
  )
}

df <- read.csv(data_path, stringsAsFactors = FALSE)

cat("\n[1] Kich thuoc du lieu - dim(df):\n")
print(dim(df))

cat("\n[2] 6 dong dau tien - head(df):\n")
print(head(df))

cat("\n[3] Cau truc du lieu - str(df):\n")
str(df)

cat("\n[4] Tom tat du lieu - summary(df):\n")
print(summary(df))

# ---------------------------------------------------------
# 2. Kiem tra missing value
# ---------------------------------------------------------
missing_counts <- colSums(is.na(df))

cat("\n===== KIEM TRA MISSING VALUE =====\n")
print(missing_counts)

if (sum(missing_counts) == 0) {
  cat("Bo du lieu khong co missing value.\n")
}

missing_df <- data.frame(
  variable = names(missing_counts),
  missing_count = as.integer(missing_counts)
)

write.csv(
  missing_df,
  file.path(output_dir, "missing_values.csv"),
  row.names = FALSE
)

# ---------------------------------------------------------
# 3. Phan tich bien muc tieu churn
# ---------------------------------------------------------
if (!"churn" %in% names(df)) {
  stop("Khong tim thay bien muc tieu 'churn' trong bo du lieu.")
}

churn_table <- table(df$churn)
churn_prop <- prop.table(churn_table)

cat("\n===== PHAN TICH BIEN MUC TIEU churn =====\n")
cat("Bang tan so - table(df$churn):\n")
print(churn_table)

cat("\nBang ty le - prop.table(table(df$churn)):\n")
print(churn_prop)

churn_distribution_df <- data.frame(
  churn = names(churn_table),
  count = as.integer(churn_table),
  proportion = as.numeric(churn_prop)
)

write.csv(
  churn_distribution_df,
  file.path(output_dir, "churn_distribution.csv"),
  row.names = FALSE
)

cat(
  "\nGiai thich ngan:\n",
  "- churn = yes: khach hang roi mang (positive class).\n",
  "- churn = no: khach hang khong roi mang.\n",
  sep = ""
)

if (all(c("yes", "no") %in% names(churn_prop))) {
  if (churn_prop["yes"] < churn_prop["no"]) {
    cat("- Ty le 'yes' thap hon 'no', du lieu co xu huong mat can bang lop.\n")
  } else {
    cat("- Ty le 'yes' khong thap hon 'no', du lieu khong co dau hieu mat can bang ro ret.\n")
  }
}

# ---------------------------------------------------------
# 4. Phan loai bien so va bien phan loai
# ---------------------------------------------------------
numeric_cols <- names(df)[sapply(df, is.numeric)]
categorical_cols <- names(df)[sapply(
  df,
  function(x) is.character(x) || is.factor(x) || is.logical(x)
)]

cat("\n===== PHAN LOAI BIEN =====\n")
cat("Danh sach bien so:\n")
print(numeric_cols)

cat("\nDanh sach bien phan loai:\n")
print(categorical_cols)

variable_types_df <- data.frame(
  variable = names(df),
  detected_type = ifelse(names(df) %in% numeric_cols, "numeric", "categorical")
)

write.csv(
  variable_types_df,
  file.path(output_dir, "variable_types.csv"),
  row.names = FALSE
)

# ---------------------------------------------------------
# 5. Phan tich tuong quan
# ---------------------------------------------------------
cat("\n===== PHAN TICH TUONG QUAN =====\n")

if (length(numeric_cols) < 2) {
  stop("Khong du bien so de tinh ma tran tuong quan.")
}

cor_matrix <- cor(df[, numeric_cols, drop = FALSE], use = "complete.obs")

write.csv(
  cor_matrix,
  file.path(output_dir, "correlation_matrix.csv"),
  row.names = TRUE
)

pair_map <- data.frame(
  minutes_var = c(
    "total_day_minutes",
    "total_eve_minutes",
    "total_night_minutes",
    "total_intl_minutes"
  ),
  charge_var = c(
    "total_day_charge",
    "total_eve_charge",
    "total_night_charge",
    "total_intl_charge"
  ),
  stringsAsFactors = FALSE
)

pair_results <- data.frame(
  minutes_var = character(0),
  charge_var = character(0),
  correlation = numeric(0),
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(pair_map))) {
  minutes_name <- pair_map$minutes_var[i]
  charge_name <- pair_map$charge_var[i]

  if (minutes_name %in% numeric_cols && charge_name %in% numeric_cols) {
    corr_value <- cor(df[[minutes_name]], df[[charge_name]], use = "complete.obs")
  } else {
    corr_value <- NA_real_
  }

  pair_results <- rbind(
    pair_results,
    data.frame(
      minutes_var = minutes_name,
      charge_var = charge_name,
      correlation = corr_value,
      stringsAsFactors = FALSE
    )
  )
}

cat("Tuong quan 4 cap minutes-charge:\n")
print(pair_results)

write.csv(
  pair_results,
  file.path(output_dir, "minutes_charge_correlations.csv"),
  row.names = FALSE
)

# ---------------------------------------------------------
# 6. De xuat bien nen giu hoac loai
# ---------------------------------------------------------
cat("\n===== GOI Y CHON BIEN =====\n")

charge_to_minutes <- c(
  total_day_charge = "total_day_minutes",
  total_eve_charge = "total_eve_minutes",
  total_night_charge = "total_night_minutes",
  total_intl_charge = "total_intl_minutes"
)

minutes_vars <- unname(charge_to_minutes)
charge_vars <- names(charge_to_minutes)

feature_selection_suggestion <- data.frame(
  variable = character(0),
  decision = character(0),
  reason = character(0),
  stringsAsFactors = FALSE
)

for (var_name in names(df)) {
  decision <- "keep"
  reason <- "Giu cho buoc phan tich va mo hinh baseline ngay 2."

  if (var_name == "churn") {
    decision <- "keep"
    reason <- "Bien muc tieu cua bai toan du doan roi mang."
  } else if (var_name %in% charge_vars) {
    matched_minutes <- charge_to_minutes[[var_name]]
    corr_row <- pair_results[pair_results$charge_var == var_name, , drop = FALSE]
    corr_value <- corr_row$correlation[1]

    if (!is.na(corr_value) && abs(corr_value) >= 0.99) {
      decision <- "drop"
      reason <- paste0(
        "Bien charge tuong quan rat cao voi ", matched_minutes,
        "; cuoc phi thuong duoc tinh tu thoi luong goi, nen giu charge se gay trung lap thong tin."
      )
    } else {
      decision <- "consider"
      reason <- paste0(
        "Can xem xet them vi charge lien quan truc tiep den ", matched_minutes,
        ", nhung tuong quan chua dat muc gan nhu tuyet doi."
      )
    }
  } else if (var_name %in% minutes_vars) {
    decision <- "keep"
    reason <- "Giu lai vi phan anh truc tiep hanh vi su dung dich vu cua khach hang."
  } else if (var_name %in% categorical_cols) {
    decision <- "keep"
    reason <- "Bien phan loai co y nghia thuc tien, chua co bang chung trong ngay 2 de loai bo."
  } else if (var_name %in% numeric_cols) {
    decision <- "keep"
    reason <- "Bien so nay chua phat hien trung lap thong tin manh trong buoc phan tich tuong quan."
  }

  feature_selection_suggestion <- rbind(
    feature_selection_suggestion,
    data.frame(
      variable = var_name,
      decision = decision,
      reason = reason,
      stringsAsFactors = FALSE
    )
  )
}

print(feature_selection_suggestion)

write.csv(
  feature_selection_suggestion,
  file.path(output_dir, "feature_selection_suggestion.csv"),
  row.names = FALSE
)

# ---------------------------------------------------------
# 7. In ket luan ngan de dua vao bao cao
# ---------------------------------------------------------
cat("\n===== KET LUAN NGAN CHO BAO CAO =====\n")

n_rows <- nrow(df)
n_cols <- ncol(df)

yes_count <- if ("yes" %in% names(churn_table)) as.integer(churn_table["yes"]) else NA_integer_
no_count <- if ("no" %in% names(churn_table)) as.integer(churn_table["no"]) else NA_integer_
yes_prop <- if ("yes" %in% names(churn_prop)) as.numeric(churn_prop["yes"]) else NA_real_
no_prop <- if ("no" %in% names(churn_prop)) as.numeric(churn_prop["no"]) else NA_real_

missing_message <- if (sum(missing_counts) == 0) {
  "Bo du lieu khong co missing value."
} else {
  paste0("Bo du lieu co tong cong ", sum(missing_counts), " missing value.")
}

imbalance_message <- "Chua du thong tin de ket luan muc do mat can bang lop."
if (!is.na(yes_prop) && !is.na(no_prop)) {
  if (yes_prop < no_prop) {
    imbalance_message <- paste0(
      "Ty le churn = yes thap hon churn = no, vi vay du lieu co xu huong mat can bang lop."
    )
  } else {
    imbalance_message <- "Ty le 2 lop khong cho thay su chenhlech ro ret."
  }
}

drop_candidates <- feature_selection_suggestion$variable[
  feature_selection_suggestion$decision == "drop"
]

redundancy_message <- if (length(drop_candidates) > 0) {
  paste0(
    "Cac bien trung thong tin manh gom: ",
    paste(drop_candidates, collapse = ", "),
    "."
  )
} else {
  "Chua phat hien bien nao co the ket luan trung thong tin manh de loai ngay o buoc nay."
}

drop_message <- if (length(drop_candidates) > 0) {
  paste0(
    "De xuat loai: ",
    paste(drop_candidates, collapse = ", "),
    " vi tuong quan rat cao voi cac bien minutes tuong ung va y nghia thuc tien cho thay charge duoc tinh tu minutes."
  )
} else {
  "Tam thoi chua de xuat loai bien nao chi dua tren ket qua tuong quan hien tai."
}

cat(
  sprintf("- Du lieu co %d dong va %d cot.\n", n_rows, n_cols),
  "- Bien muc tieu la churn.\n",
  "- churn = yes co nghia la khach hang roi mang va day la positive class.\n",
  if (!is.na(yes_count) && !is.na(no_count) && !is.na(yes_prop) && !is.na(no_prop)) {
    sprintf(
      "- churn = yes co %d dong (%.2f%%), churn = no co %d dong (%.2f%%).\n",
      yes_count, yes_prop * 100, no_count, no_prop * 100
    )
  } else {
    "- Chua trich xuat du du lieu cho 2 lop churn = yes/no.\n"
  },
  paste0("- ", imbalance_message, "\n"),
  paste0("- ", missing_message, "\n"),
  paste0("- ", redundancy_message, "\n"),
  paste0("- ", drop_message, "\n"),
  sep = ""
)

cat("\nCac bang da duoc luu trong thu muc: outputs/tables\n")
cat("===== KET THUC PHAN TICH NGAY 2 BANG R =====\n")
