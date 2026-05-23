"""
Ngay 2 - Random Forest baseline cho bai toan churn

Luu y:
- Chi dung Python de tien xu ly cho mo hinh va xay dung baseline.
- Khong dung Python de thay the phan phan tich thong ke da giao cho R.
- Khong lam CRD / CRFD / repeated k-fold / Levene / Tukey / interaction plot.
"""

import os
from pathlib import Path

import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, f1_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder


# ---------------------------------------------------------
# 1. Doc du lieu
# ---------------------------------------------------------
print("===== BAT DAU RANDOM FOREST BASELINE =====")
print("Thu muc lam viec hien tai:")
print(os.getcwd())

project_root = Path(__file__).resolve().parents[1]
data_path = project_root / "data" / "mlc_churn.csv"
output_dir = project_root / "outputs" / "tables"
output_dir.mkdir(parents=True, exist_ok=True)

if not data_path.exists():
    raise FileNotFoundError(
        "Khong tim thay file du lieu tai "
        f"{data_path}. "
        "Hay kiem tra os.getcwd() va dam bao ban dang chay lenh "
        "'python python/01_day2_rf_baseline.py' tu thu muc goc cua project mlc_churn_project."
    )

df = pd.read_csv(data_path)

print("\nKich thuoc du lieu:")
print(df.shape)


# ---------------------------------------------------------
# 2. Loai cac bien da chot tu phan R
# ---------------------------------------------------------
# Co the chinh sua danh sach nay sau khi xem output tu RStudio
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

print("\nDanh sach bien se loai truoc khi tao mo hinh:")
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


# ---------------------------------------------------------
# 4. Chia train/test
# ---------------------------------------------------------
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=1234,
    stratify=y,
)

print("\nTy le lop trong tap train:")
print(y_train.value_counts(normalize=True).sort_index())
print("So luong lop trong tap train:")
print(y_train.value_counts().sort_index())

print("\nTy le lop trong tap test:")
print(y_test.value_counts(normalize=True).sort_index())
print("So luong lop trong tap test:")
print(y_test.value_counts().sort_index())


# ---------------------------------------------------------
# 5. Tien xu ly bien dau vao
# ---------------------------------------------------------
preprocessor = ColumnTransformer(
    transformers=[
        ("categorical", OneHotEncoder(handle_unknown="ignore"), categorical_cols),
        ("numeric", "passthrough", numeric_cols),
    ]
)


# ---------------------------------------------------------
# 6. Xay dung mo hinh Random Forest baseline
# ---------------------------------------------------------
rf_model = RandomForestClassifier(
    random_state=1234,
    max_depth=None,
)

model = Pipeline(
    steps=[
        ("preprocessor", preprocessor),
        ("classifier", rf_model),
    ]
)

model.fit(X_train, y_train)


# ---------------------------------------------------------
# 7. Danh gia mo hinh
# ---------------------------------------------------------
y_pred = model.predict(X_test)

f1_positive_yes = f1_score(y_test, y_pred, pos_label=1)
cm = confusion_matrix(y_test, y_pred)
report = classification_report(
    y_test,
    y_pred,
    target_names=["no", "yes"],
    zero_division=0,
)

print("\n===== KET QUA BASELINE =====")
print(f"F1-score (positive class = yes): {f1_positive_yes:.6f}")

print("\nConfusion matrix:")
print(cm)

print("\nClassification report:")
print(report)


# ---------------------------------------------------------
# 8. Luu ket qua baseline
# ---------------------------------------------------------
baseline_result = pd.DataFrame(
    [
        {
            "model": "RandomForestClassifier",
            "random_seed": 1234,
            "max_depth": "None",
            "dropped_features": ", ".join(actual_dropped_features),
            "f1_positive_yes": f1_positive_yes,
        }
    ]
)

baseline_output_path = output_dir / "baseline_result.csv"
baseline_result.to_csv(baseline_output_path, index=False)

print(f"\nDa luu ket qua baseline tai: {baseline_output_path}")
print("===== KET THUC RANDOM FOREST BASELINE =====")
