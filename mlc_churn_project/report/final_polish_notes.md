# Final Polish Notes - Project `mlc_churn`

## 1. Kiểm tra file cần nộp

### 1.1. File hiện đã có

- [report_draft_day7.md](/d:/pttn/mlc_churn_project/report/report_draft_day7.md)
- [crd_results.csv](/d:/pttn/mlc_churn_project/results/crd_results.csv)
- [crfd_results.csv](/d:/pttn/mlc_churn_project/results/crfd_results.csv)

### 1.2. File hiện chưa có

- `report/final_report.docx`
- `report/final_report.md`
- `report/final_report.pdf`

### 1.3. Ý nghĩa của các file còn thiếu

- Thiếu `final_report.docx` hoặc `final_report.md` không ảnh hưởng đến nội dung học thuật, nhưng cần có một bản báo cáo cuối để trình bày chính thức.
- Thiếu `final_report.pdf` có ảnh hưởng trực tiếp đến việc nộp bài nếu giảng viên yêu cầu nộp PDF.
- Hai file kết quả thí nghiệm `crd_results.csv` và `crfd_results.csv` đã sẵn sàng để nộp kèm.

### 1.4. Gợi ý bước tạo file cuối

- Dùng [report_draft_day7.md](/d:/pttn/mlc_churn_project/report/report_draft_day7.md) làm nội dung gốc.
- Chèn bảng và hình theo danh sách ở các mục dưới.
- Xuất sang Word hoặc PDF.
- Lưu bản cuối thành `report/final_report.docx` hoặc `report/final_report.md`.
- Xuất PDF thành `report/final_report.pdf`.

## 2. Danh sách bảng cần chèn

### Bảng 1. Thông tin tổng quan bộ dữ liệu

- Nội dung: số dòng `5000`, số cột `20`, biến mục tiêu `churn`, positive class `yes`.
- Nên đặt ở: Mục `2. Mô tả bộ dữ liệu`.
- Caption đề xuất: `Bảng 1. Thông tin tổng quan của bộ dữ liệu mlc_churn`.
- Gợi ý trình bày: bảng ngắn 4 dòng, không cần quá chi tiết.

### Bảng 2. Phân bố biến churn

- Nội dung: `no = 4293 (85.86%)`, `yes = 707 (14.14%)`.
- Nên đặt ở: Mục `3. Phân tích biến mục tiêu và mất cân bằng lớp`.
- Caption đề xuất: `Bảng 2. Phân bố của biến mục tiêu churn`.
- Nguồn dữ liệu: [churn_distribution.csv](/d:/pttn/mlc_churn_project/outputs/tables/churn_distribution.csv).

### Bảng 3. Tương quan giữa các cặp minutes-charge

- Nội dung: 4 cặp `minutes-charge` với hệ số tương quan tương ứng.
- Nên đặt ở: Mục `4. Tiền xử lý dữ liệu và lựa chọn biến`.
- Caption đề xuất: `Bảng 3. Tương quan giữa các cặp biến thời lượng gọi và cước phí`.
- Nguồn dữ liệu: [minutes_charge_correlations.csv](/d:/pttn/mlc_churn_project/outputs/tables/minutes_charge_correlations.csv).

### Bảng 4. Các biến bị loại khỏi mô hình

- Nội dung: `total_day_charge`, `total_eve_charge`, `total_night_charge`, `total_intl_charge`, kèm lý do loại.
- Nên đặt ở: Mục `4. Tiền xử lý dữ liệu và lựa chọn biến`.
- Caption đề xuất: `Bảng 4. Các biến bị loại và lý do loại khỏi mô hình`.
- Nguồn dữ liệu: [feature_selection_suggestion.csv](/d:/pttn/mlc_churn_project/outputs/tables/feature_selection_suggestion.csv).
- Gợi ý rút gọn: chỉ giữ 4 dòng cho 4 biến bị loại, không cần chèn toàn bộ bảng gợi ý nếu quá dài.

### Bảng 5. Kết quả Random Forest baseline

- Nội dung: `F1-score = 0.758621`, precision lớp `yes = 0.97`, recall lớp `yes = 0.62`, F1 lớp `yes = 0.76`.
- Nên đặt ở: Mục `5. Mô hình Random Forest baseline`.
- Caption đề xuất: `Bảng 5. Kết quả mô hình Random Forest baseline`.
- Nguồn dữ liệu: [baseline_result.csv](/d:/pttn/mlc_churn_project/outputs/tables/baseline_result.csv).
- Gợi ý bổ sung: có thể chèn thêm ma trận nhầm lẫn ngay dưới bảng hoặc trong phần mô tả văn bản.

### Bảng 6. Summary CRD theo k

- Nội dung: `n`, `mean`, `sd`, `se`, `ci_lower`, `ci_upper` cho `k = 3, 5, 10`.
- Nên đặt ở: Mục `7. Phân tích kết quả CRD`.
- Caption đề xuất: `Bảng 6. Thống kê mô tả F1-score theo các mức k trong thí nghiệm CRD`.
- Nguồn dữ liệu: [crd_summary_by_k.csv](/d:/pttn/mlc_churn_project/outputs/tables/crd_summary_by_k.csv).

### Bảng 7. Levene test CRD

- Nội dung: kết quả `leveneTest(f1 ~ k)`.
- Nên đặt ở: Mục `7. Phân tích kết quả CRD`.
- Caption đề xuất: `Bảng 7. Kết quả kiểm định Levene cho thí nghiệm CRD`.
- Nguồn dữ liệu: output RStudio.
- Gợi ý trình bày: chèn lại thủ công thành bảng nhỏ gồm `Df`, `F value`, `Pr(>F)`.

### Bảng 8. ANOVA CRD

- Nội dung: kết quả `anova(model_crd)`.
- Nên đặt ở: Mục `7. Phân tích kết quả CRD`.
- Caption đề xuất: `Bảng 8. Kết quả ANOVA cho ảnh hưởng của k trong thí nghiệm CRD`.
- Nguồn dữ liệu: output RStudio.
- Gợi ý trình bày: chỉ cần các cột `Df`, `Sum Sq`, `Mean Sq`, `F value`, `Pr(>F)`.

### Bảng 9. TukeyHSD CRD

- Nội dung: các cặp `5-3`, `10-3`, `10-5`.
- Nên đặt ở: Mục `7. Phân tích kết quả CRD`.
- Caption đề xuất: `Bảng 9. Kết quả so sánh cặp TukeyHSD cho thí nghiệm CRD`.
- Nguồn dữ liệu: [crd_tukey_results.csv](/d:/pttn/mlc_churn_project/outputs/tables/crd_tukey_results.csv).

### Bảng 10. Summary CRFD theo k và max_depth

- Nội dung: `n`, `mean`, `sd`, `se`, `ci_lower`, `ci_upper` cho từng tổ hợp `k` và `max_depth`.
- Nên đặt ở: Mục `9. Phân tích kết quả CRFD`.
- Caption đề xuất: `Bảng 10. Thống kê mô tả F1-score theo tổ hợp k và max_depth trong thí nghiệm CRFD`.
- Nguồn dữ liệu: [crfd_summary_by_k_depth.csv](/d:/pttn/mlc_churn_project/outputs/tables/crfd_summary_by_k_depth.csv).

### Bảng 11. ANOVA CRFD

- Nội dung: kết quả `anova(model_crfd)` cho `k`, `max_depth`, `k:max_depth`.
- Nên đặt ở: Mục `9. Phân tích kết quả CRFD`.
- Caption đề xuất: `Bảng 11. Kết quả ANOVA cho các yếu tố k, max_depth và tương tác trong thí nghiệm CRFD`.
- Nguồn dữ liệu: output RStudio.
- Gợi ý trình bày: chỉ giữ các cột `Df`, `Sum Sq`, `Mean Sq`, `F value`, `Pr(>F)`.

### Bảng 12. TukeyHSD CRFD

- Nội dung: kết quả TukeyHSD cho `k`, `max_depth`, và có thể rút gọn phần tương tác.
- Nên đặt ở: Mục `9. Phân tích kết quả CRFD`.
- Caption đề xuất: `Bảng 12. Kết quả so sánh cặp TukeyHSD cho thí nghiệm CRFD`.
- Nguồn dữ liệu:
  - [crfd_tukey_k.csv](/d:/pttn/mlc_churn_project/outputs/tables/crfd_tukey_k.csv)
  - [crfd_tukey_max_depth.csv](/d:/pttn/mlc_churn_project/outputs/tables/crfd_tukey_max_depth.csv)
  - [crfd_tukey_interaction.csv](/d:/pttn/mlc_churn_project/outputs/tables/crfd_tukey_interaction.csv)
- Gợi ý rút gọn: trong phần thân báo cáo chỉ nên trình bày đầy đủ cho `k` và `max_depth`; bảng Tukey của phần tương tác nên đưa vào phụ lục nếu quá dài.

## 3. Danh sách hình cần chèn

### Hình 1. CRD boxplot

- File: [crd_boxplot.png](/d:/pttn/mlc_churn_project/figures/crd_boxplot.png)
- Nên đặt ở: Mục `7. Phân tích kết quả CRD`.
- Caption đề xuất: `Hình 1. Boxplot F1-score theo các mức k trong thí nghiệm CRD`.
- Câu dẫn trước hình: `Để trực quan hóa sự phân bố F1-score giữa các mức k, Hình 1 trình bày boxplot của ba nhóm thí nghiệm.`
- Câu nhận xét sau hình: `Hình 1 cho thấy phân bố F1-score của ba mức k có chồng lấn đáng kể; nhóm k = 10 có xu hướng nhỉnh hơn, nhưng khác biệt trực quan không lớn.`

### Hình 2. CRD mean F1 và khoảng tin cậy 95%

- File: [crd_mean_ci.png](/d:/pttn/mlc_churn_project/figures/crd_mean_ci.png)
- Nên đặt ở: Mục `7. Phân tích kết quả CRD`.
- Caption đề xuất: `Hình 2. F1-score trung bình và khoảng tin cậy 95% theo các mức k trong thí nghiệm CRD`.
- Câu dẫn trước hình: `Hình 2 minh họa mean F1-score và khoảng tin cậy 95% của từng mức k.`
- Câu nhận xét sau hình: `Các khoảng tin cậy chồng lấn mạnh, cho thấy khác biệt giữa các mức k chưa rõ rệt về mặt trực quan.`

### Hình 3. CRFD boxplot theo max_depth/k

- File: [crfd_boxplot_by_depth.png](/d:/pttn/mlc_churn_project/figures/crfd_boxplot_by_depth.png)
- Nên đặt ở: Mục `9. Phân tích kết quả CRFD`.
- Caption đề xuất: `Hình 3. Boxplot F1-score theo max_depth, phân tách theo các mức k trong thí nghiệm CRFD`.
- Câu dẫn trước hình: `Để so sánh phân bố F1-score giữa các mức max_depth trong từng mức k, Hình 3 trình bày boxplot theo cấu trúc CRFD.`
- Câu nhận xét sau hình: `Hình 3 cho thấy các nhóm max_depth = None có F1-score cao hơn rõ rệt so với max_depth = 5 và max_depth = 3 ở cả ba mức k.`

### Hình 4. CRFD mean F1 và khoảng tin cậy 95%

- File: [crfd_mean_ci.png](/d:/pttn/mlc_churn_project/figures/crfd_mean_ci.png)
- Nên đặt ở: Mục `9. Phân tích kết quả CRFD`.
- Caption đề xuất: `Hình 4. F1-score trung bình và khoảng tin cậy 95% theo tổ hợp k và max_depth trong thí nghiệm CRFD`.
- Câu dẫn trước hình: `Hình 4 thể hiện mean F1-score và khoảng tin cậy 95% của từng tổ hợp k và max_depth.`
- Câu nhận xét sau hình: `Hình 4 cho thấy ảnh hưởng của max_depth rõ rệt hơn nhiều so với ảnh hưởng của k, với nhóm max_depth = None luôn nằm cao nhất.`

### Hình 5. Interaction plot giữa k và max_depth

- File: [crfd_interaction_plot.png](/d:/pttn/mlc_churn_project/figures/crfd_interaction_plot.png)
- Nên đặt ở: Mục `9. Phân tích kết quả CRFD`.
- Caption đề xuất: `Hình 5. Interaction plot giữa k và max_depth đối với F1-score trong thí nghiệm CRFD`.
- Câu dẫn trước hình: `Để đánh giá trực quan khả năng tồn tại tương tác giữa k và max_depth, Hình 5 trình bày interaction plot của hai yếu tố.`
- Câu nhận xét sau hình: `Các đường có khác biệt về mức nhưng không cắt nhau rõ rệt, cho thấy tương tác yếu hoặc không rõ; nhận xét này phù hợp với kết quả ANOVA khi p-value của k:max_depth lớn hơn 0.05.`

## 4. Tài liệu tham khảo

Có thể sử dụng trực tiếp mục tài liệu tham khảo sau trong báo cáo:

[1] M. Kuhn, *modeldata: Data Sets Useful for Modeling Examples*, R package version 1.5.1, 2025.

[2] R Core Team, *R: A Language and Environment for Statistical Computing*, R Foundation for Statistical Computing, Vienna, Austria, 2024.

[3] L. Breiman, “Random Forests,” *Machine Learning*, vol. 45, pp. 5–32, 2001.

[4] J. Lawson, *Design and Analysis of Experiments with R*, CRC Press, 2015.

Nếu cần bổ sung thêm tài liệu công cụ, có thể thêm:

[5] F. Pedregosa et al., “Scikit-learn: Machine Learning in Python,” *Journal of Machine Learning Research*, vol. 12, pp. 2825–2830, 2011.

[6] H. Wickham, *ggplot2: Elegant Graphics for Data Analysis*, Springer, 2016.

## 5. Rà soát văn phong lần cuối

Trước khi xuất PDF, cần rà soát để đảm bảo:

- Không dùng văn nói hoặc cách diễn đạt kiểu hội thoại.
- Không dùng các từ như `mình`, `bọn tôi`, `code chạy được rồi`.
- Dùng các cụm như `nhóm`, `bộ dữ liệu`, `mô hình`, `thí nghiệm`.
- Luôn viết đúng `positive class = yes`.
- Không dùng accuracy làm độ đo chính.
- Không nhầm `CRD` với `CRFD`.
- Không nhầm `max_depth = None` với `max_depth = 0`.
- Không viết `không ảnh hưởng` khi `p-value >= 0.05`; cần viết `chưa có bằng chứng thống kê cho thấy ...`.
- Khi nói về cấu hình nổi bật, dùng cụm `tổ hợp có F1 trung bình cao nhất trong thí nghiệm`.

## 6. Checklist trước khi xuất PDF

- [ ] Báo cáo có đủ các mục chính.
- [ ] Đã chèn bảng mô tả dữ liệu.
- [ ] Đã chèn bảng phân bố churn.
- [ ] Đã chèn bảng tương quan minutes-charge.
- [ ] Đã chèn bảng baseline.
- [ ] Đã chèn bảng CRD summary.
- [ ] Đã chèn Levene test CRD.
- [ ] Đã chèn ANOVA CRD.
- [ ] Đã chèn TukeyHSD CRD.
- [ ] Đã chèn bảng CRFD summary.
- [ ] Đã chèn ANOVA CRFD.
- [ ] Đã chèn interaction plot.
- [ ] Đã kiểm tra caption hình/bảng.
- [ ] Đã có tài liệu tham khảo.
- [ ] Đã kiểm tra positive class = yes.
- [ ] Đã kiểm tra random seed = 1234.
- [ ] Đã kiểm tra repeat = 10.
- [ ] Đã kiểm tra stratified k-fold.
- [ ] Đã kiểm tra không bịa p-value.
- [ ] Đã xuất PDF.
- [ ] Đã mở PDF để kiểm tra lỗi font/hình/bảng.
- [ ] Đã chuẩn bị crd_results.csv.
- [ ] Đã chuẩn bị crfd_results.csv.

## 7. Danh sách file cần nộp

### 7.1. Bắt buộc

- [crd_results.csv](/d:/pttn/mlc_churn_project/results/crd_results.csv)
- [crfd_results.csv](/d:/pttn/mlc_churn_project/results/crfd_results.csv)
- `final_report.pdf`

### 7.2. Nên giữ trong thư mục project

- [report_draft_day7.md](/d:/pttn/mlc_churn_project/report/report_draft_day7.md)
- `final_report.docx` hoặc `final_report.md`
- các file hình trong thư mục [figures](/d:/pttn/mlc_churn_project/figures)
- các bảng trong thư mục [outputs/tables](/d:/pttn/mlc_churn_project/outputs/tables)
