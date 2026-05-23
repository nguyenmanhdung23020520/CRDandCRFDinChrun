"""
Ngay 3 - Thi nghiem CRD cho Random Forest

Muc tieu:
- Danh gia anh huong cua so fold k den F1-score.
- Chi dung Python de chay repeated stratified k-fold va luu ket qua.
- Khong dung Python de thay the phan phan tich thong ke cua RStudio.
- Day 3 chi lam CRD, khong lam CRFD.
"""

import os
from pathlib import Path

import pandas as pd
from sklearn.base import clone
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score
from sklearn.model_selection import StratifiedKFold
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder


# ---------------------------------------------------------
# 1. Doc du lieu
# ---------------------------------------------------------
print("===== BAT DAU THI NGHIEM CRD - DAY 3 =====")
print("Thu muc lam viec hien tai:")
print(os.getcwd())

project_root = Path(__file__).resolve().parents[1]
data_path = project_root / "data" / "mlc_churn.csv"
results_dir = project_root / "results"
results_dir.mkdir(parents=True, exist_ok=True)

if not data_path.exists():
    raise FileNotFoundError(
        "Khong tim thay file du lieu tai "
        f"{data_path}. "
        "Hay kiem tra os.getcwd() va dam bao ban dang chay lenh "
        "'python python/02_day3_run_crd_experiment.py' tu thu muc goc cua project mlc_churn_project."
    )

df = pd.read_csv(data_path)

print("\nKich thuoc du lieu:")
print(df.shape)


# ---------------------------------------------------------
# 2. Loai bien charge da chot tu Day 2
# ---------------------------------------------------------
dropped_features = [
    "total_day_charge",
    "total_eve_charge",
    "total_night_charge",
    "total_intl_charge",
]

missing_drop_columns = [col for col in dropped_features if col not in df.columns]
if missing_drop_columns:
    print("\nCanh bao: cac cot sau khong ton tai trong du lieu nen se bo qua:")
    print(missing_drop_columns)

actual_dropped_features = [col for col in dropped_features if col in df.columns]

print("\nDanh sach bien se loai:")
print(actual_dropped_features)


# ---------------------------------------------------------
# 3. Chuan bi X va y
# ---------------------------------------------------------
target_col = "churn"
if target_col not in df.columns:
    raise ValueError("Khong tim thay cot 'churn' trong du lieu.")

df[target_col] = df[target_col].astype(str).str.strip().str.lower()
y = df[target_col].map({"no": 0, "yes": 1})

if y.isna().any():
    invalid_values = sorted(df.loc[y.isna(), target_col].unique().tolist())
    raise ValueError(
        "Cot 'churn' chua gia tri ngoai 'yes'/'no': "
        f"{invalid_values}"
    )

X = df.drop(columns=actual_dropped_features + [target_col])

categorical_cols = X.select_dtypes(include=["object", "category", "bool"]).columns.tolist()
numeric_cols = X.select_dtypes(include=["number"]).columns.tolist()

print("\nSo bien dau vao sau khi loai:")
print(X.shape[1])
print("Bien so:")
print(numeric_cols)
print("Bien phan loai:")
print(categorical_cols)

print("\nTy le lop y:")
print(y.value_counts(normalize=True).sort_index())
print("So luong tung lop y:")
print(y.value_counts().sort_index())


# ---------------------------------------------------------
# 4. Tao pipeline tien xu ly va mo hinh
# ---------------------------------------------------------
preprocessor = ColumnTransformer(
    transformers=[
        ("categorical", OneHotEncoder(handle_unknown="ignore"), categorical_cols),
        ("numeric", "passthrough", numeric_cols),
    ]
)

base_model = Pipeline(
    steps=[
        ("preprocessor", preprocessor),
        (
            "classifier",
            RandomForestClassifier(
                random_state=1234,
                max_depth=None,
            ),
        ),
    ]
)


# ---------------------------------------------------------
# 5. Chay repeated stratified k-fold
# ---------------------------------------------------------
k_values = [3, 5, 10]
n_repeats = 10
random_seed = 1234

results = []

for k in k_values:
    print(f"\nDang chay CRD voi k = {k}")

    for repeat_idx in range(1, n_repeats + 1):
        skf = StratifiedKFold(
            n_splits=k,
            shuffle=True,
            random_state=random_seed + repeat_idx,
        )

        for fold_idx, (train_index, valid_index) in enumerate(skf.split(X, y), start=1):
            X_train = X.iloc[train_index]
            X_valid = X.iloc[valid_index]
            y_train = y.iloc[train_index]
            y_valid = y.iloc[valid_index]

            model = clone(base_model)
            model.fit(X_train, y_train)
            y_pred = model.predict(X_valid)

            fold_f1 = f1_score(y_valid, y_pred, pos_label=1)

            results.append(
                {
                    "experiment": "CRD",
                    "repeat": repeat_idx,
                    "k": k,
                    "fold": fold_idx,
                    "max_depth": "None",
                    "f1": fold_f1,
                }
            )

results_df = pd.DataFrame(results)


# ---------------------------------------------------------
# 6. Luu ket qua
# ---------------------------------------------------------
results_path = results_dir / "crd_results.csv"
results_df.to_csv(results_path, index=False)

rows_by_k = results_df.groupby("k").size().reset_index(name="n_rows")
mean_f1_by_k = results_df.groupby("k", as_index=False)["f1"].mean()

print("\n===== TOM TAT KET QUA CRD =====")
print("So dong ket qua:")
print(len(results_df))

print("\nSo dong theo tung k:")
print(rows_by_k)

print("\nMean F1 theo tung k:")
print(mean_f1_by_k)

print(f"\nDa luu ket qua tai: {results_path}")
print("===== KET THUC THI NGHIEM CRD - DAY 3 =====")
