# Bản nháp báo cáo Day 5 - Project `mlc_churn`

## 1. Giới thiệu bài toán

Bài toán của project là dự đoán khách hàng có rời mạng hay không, với biến mục tiêu là `churn`. Trong bối cảnh doanh nghiệp viễn thông, việc dự đoán sớm khách hàng có khả năng rời mạng có ý nghĩa thực tiễn quan trọng vì giúp doanh nghiệp chủ động xây dựng các chính sách giữ chân khách hàng, giảm thất thoát doanh thu và nâng cao chất lượng dịch vụ.

Trong nghiên cứu này, mô hình được sử dụng là `RandomForestClassifier`. Đây là mô hình học máy dựa trên tổ hợp nhiều cây quyết định, có khả năng mô hình hóa quan hệ phi tuyến và xử lý tốt dữ liệu gồm cả biến số lẫn biến phân loại. Độ đo đánh giá chính được sử dụng là `F1-score` với positive class là `churn = yes`, do dữ liệu có mất cân bằng lớp và mục tiêu quan trọng là đánh giá đồng thời precision và recall đối với nhóm khách hàng rời mạng.

## 2. Mô tả bộ dữ liệu

Bộ dữ liệu `mlc_churn.csv` gồm `5000` quan sát và `20` biến. Mỗi dòng dữ liệu tương ứng với một khách hàng viễn thông. Các biến trong dữ liệu có thể chia thành một số nhóm chính như sau:

- Thông tin tài khoản, ví dụ: `account_length`, `state`, `area_code`.
- Thông tin gói dịch vụ, ví dụ: `international_plan`, `voice_mail_plan`.
- Thông tin sử dụng cuộc gọi theo từng khung thời gian, ví dụ: `total_day_minutes`, `total_eve_minutes`, `total_night_minutes`, `total_intl_minutes` và các biến số cuộc gọi tương ứng.
- Số lần liên hệ chăm sóc khách hàng, ví dụ: `number_customer_service_calls`.
- Biến mục tiêu `churn`.

Biến mục tiêu `churn` nhận hai giá trị `yes` và `no`, trong đó `yes` biểu thị khách hàng rời mạng, còn `no` biểu thị khách hàng không rời mạng.

## 3. Phân tích biến mục tiêu

Kết quả phân tích cho thấy:

- `churn = yes`: `707` khách hàng, chiếm `14.14%`.
- `churn = no`: `4293` khách hàng, chiếm `85.86%`.

Phân bố này cho thấy bộ dữ liệu bị mất cân bằng lớp, vì số lượng khách hàng rời mạng thấp hơn đáng kể so với số lượng khách hàng không rời mạng. Trong bối cảnh này, nếu chỉ dùng accuracy thì mô hình có thể đạt giá trị cao ngay cả khi dự đoán kém cho lớp thiểu số. Do đó, việc sử dụng `F1-score` làm độ đo đánh giá là phù hợp hơn, đặc biệt khi positive class là `yes`.

Ngoài ra, do dữ liệu mất cân bằng lớp, các bước chia dữ liệu trong baseline và các thí nghiệm cross-validation đều sử dụng chiến lược `stratify` hoặc `stratified k-fold` để duy trì tỷ lệ lớp gần giống với dữ liệu gốc.

## 4. Tiền xử lý và lựa chọn biến

Kết quả kiểm tra dữ liệu cho thấy bộ dữ liệu không có missing value. Trong quá trình xây dựng mô hình, các biến phân loại gồm `state`, `area_code`, `international_plan`, và `voice_mail_plan` được mã hóa bằng `OneHotEncoder(handle_unknown="ignore")`. Biến mục tiêu `churn` được mã hóa theo quy ước `yes -> 1` và `no -> 0`.

Phân tích tương quan trong Day 2 cho thấy bốn cặp biến `minutes-charge` có tương quan gần như tuyệt đối:

- `total_day_minutes` và `total_day_charge`
- `total_eve_minutes` và `total_eve_charge`
- `total_night_minutes` và `total_night_charge`
- `total_intl_minutes` và `total_intl_charge`

Từ đó, bốn biến sau đã được loại khỏi mô hình:

- `total_day_charge`
- `total_eve_charge`
- `total_night_charge`
- `total_intl_charge`

Lý do loại là các biến này gây trùng lặp thông tin với các biến `minutes` tương ứng, trong khi về mặt thực tiễn cước phí được tính từ thời lượng gọi. Việc loại các biến `charge` giúp giảm dư thừa thông tin đầu vào mà vẫn giữ được ý nghĩa hành vi sử dụng dịch vụ của khách hàng thông qua các biến `minutes`.

## 5. Mô hình Random Forest baseline

Mô hình baseline được xây dựng bằng `RandomForestClassifier` với `random_state = 1234` và `max_depth = None`. Dữ liệu được chia thành tập huấn luyện và tập kiểm tra theo tỷ lệ `80/20`, đồng thời sử dụng `stratify = y` để giữ tỷ lệ lớp `yes/no` gần với dữ liệu gốc.

Kết quả baseline cho thấy:

- `F1-score` với positive class = `yes`: `0.758621`
- Precision lớp `yes`: `0.97`
- Recall lớp `yes`: `0.62`

Ma trận nhầm lẫn của mô hình baseline là:

```text
[[856, 3],
 [53, 88]]
```

Kết quả này cho thấy mô hình có độ chính xác khá cao khi dự đoán một khách hàng sẽ rời mạng, thể hiện qua precision rất cao ở lớp `yes`. Tuy nhiên, recall của lớp `yes` mới ở mức `0.62`, cho thấy mô hình vẫn bỏ sót một phần khách hàng rời mạng. Vì vậy, baseline chủ yếu được sử dụng như một mốc tham chiếu ban đầu để kiểm tra pipeline tiền xử lý và đánh giá trước khi tiến hành các thí nghiệm chính ở các ngày sau.

## 6. Thiết kế thí nghiệm CRD

Trong Day 3, thí nghiệm `CRD` được sử dụng để kiểm tra ảnh hưởng của số fold `k` trong stratified cross-validation đến `F1-score` của mô hình Random Forest. Yếu tố nghiên cứu là `k`, với ba mức được khảo sát là `3`, `5`, và `10`. Mỗi mức `k` được lặp `10` lần (`repeat = 10`), sử dụng `StratifiedKFold` để đảm bảo tỷ lệ lớp được giữ ổn định trong từng fold. Trong thí nghiệm này, tham số `max_depth` được cố định ở giá trị `None`.

Kết quả chi tiết của thí nghiệm được lưu trong file `results/crd_results.csv`. Phần phân tích thống kê trong RStudio sử dụng các công cụ:

- `leveneTest()` để kiểm tra tính đồng nhất phương sai
- `lm()` và `ANOVA` để đánh giá ảnh hưởng của `k`
- `TukeyHSD()` để so sánh cặp giữa các mức `k`
- biểu đồ `boxplot`
- biểu đồ `mean confidence interval`

## 7. Phân tích kết quả CRD

Kết quả thống kê mô tả theo từng mức `k` như sau:

| k | n | mean F1 | sd | se | CI lower | CI upper |
|---|---:|---:|---:|---:|---:|---:|
| 3 | 30 | 0.740299 | 0.022036 | 0.004023 | 0.732071 | 0.748527 |
| 5 | 50 | 0.752170 | 0.033807 | 0.004781 | 0.742563 | 0.761778 |
| 10 | 100 | 0.756786 | 0.041396 | 0.004140 | 0.748572 | 0.765000 |

Về mặt mô tả, `F1-score` trung bình có xu hướng tăng nhẹ khi số fold tăng từ `3` lên `5` và `10`. Tuy nhiên, độ lệch chuẩn cũng tăng dần theo `k`, cho thấy độ biến động giữa các lần đánh giá không hoàn toàn giống nhau.

Kiểm định `Levene` cho kết quả `p-value = 0.0004759 < 0.05`, cho thấy phương sai `F1-score` giữa các nhóm `k` khác nhau có ý nghĩa thống kê. Điều này nghĩa là mức độ biến động của F1 giữa các mức `k` là không đồng nhất.

Kết quả `ANOVA` cho mô hình `lm(f1 ~ k)` cho thấy `p-value = 0.1008`, lớn hơn mức ý nghĩa `0.05`. Vì vậy, chưa có đủ bằng chứng thống kê để kết luận rằng số fold `k` ảnh hưởng có ý nghĩa thống kê đến `F1-score` của mô hình Random Forest trong phạm vi thí nghiệm này.

Kết quả `TukeyHSD()` cũng cho thấy tất cả các cặp so sánh đều có `p adj > 0.05`:

- `5 - 3`: `p adj = 0.3448`
- `10 - 3`: `p adj = 0.0825`
- `10 - 5`: `p adj = 0.7495`

Như vậy, chưa có bằng chứng thống kê để khẳng định các mức `k` khác nhau tạo ra khác biệt có ý nghĩa về `F1-score` trung bình. Hai hình `crd_boxplot.png` và `crd_mean_ci.png` được sử dụng để minh họa phân bố F1 và khoảng tin cậy 95% theo từng mức `k`.

## 8. Thiết kế thí nghiệm CRFD

Trong Day 4, thí nghiệm `CRFD` được thiết kế để đánh giá đồng thời ảnh hưởng của hai yếu tố đến `F1-score` của mô hình Random Forest. Yếu tố thứ nhất là số fold `k` với các mức `3`, `5`, và `10`. Yếu tố thứ hai là `max_depth` với các mức `3`, `5`, và `None`. Mỗi tổ hợp được lặp `10` lần, sử dụng `StratifiedKFold` để đảm bảo tính nhất quán về tỷ lệ lớp trong các fold.

Kết quả thí nghiệm được lưu trong file `results/crfd_results.csv`. Phần phân tích thống kê trong RStudio sử dụng:

- mô hình `lm(f1 ~ k * max_depth)`
- `ANOVA`
- `TukeyHSD()`
- `interaction plot`
- biểu đồ `boxplot`
- biểu đồ `mean confidence interval`

Mục tiêu của CRFD là trả lời ba câu hỏi:

1. `k` có ảnh hưởng đến `F1-score` hay không?
2. `max_depth` có ảnh hưởng đến `F1-score` hay không?
3. Có tương tác giữa `k` và `max_depth` hay không?

## 9. Phân tích kết quả CRFD

Kết quả thống kê mô tả theo từng tổ hợp `k` và `max_depth` như sau:

| k | max_depth | n | mean F1 | sd | se | CI lower | CI upper |
|---|---|---:|---:|---:|---:|---:|---:|
| 3 | 3 | 30 | 0.002254 | 0.003802 | 0.000694 | 0.000834 | 0.003673 |
| 3 | 5 | 30 | 0.064496 | 0.024049 | 0.004391 | 0.055516 | 0.073476 |
| 3 | None | 30 | 0.740299 | 0.022036 | 0.004023 | 0.732071 | 0.748527 |
| 5 | 3 | 50 | 0.001406 | 0.004262 | 0.000603 | 0.000195 | 0.002618 |
| 5 | 5 | 50 | 0.069920 | 0.030595 | 0.004327 | 0.061225 | 0.078615 |
| 5 | None | 50 | 0.752170 | 0.033807 | 0.004781 | 0.742563 | 0.761778 |
| 10 | 3 | 100 | 0.000556 | 0.003911 | 0.000391 | -0.000220 | 0.001333 |
| 10 | 5 | 100 | 0.072578 | 0.042495 | 0.004250 | 0.064145 | 0.081011 |
| 10 | None | 100 | 0.756786 | 0.041396 | 0.004140 | 0.748572 | 0.765000 |

Kết quả trên cho thấy `max_depth` tạo ra khác biệt rất lớn về `F1-score`. Với `max_depth = 3`, giá trị F1 trung bình gần như bằng `0` ở cả ba mức `k`. Với `max_depth = 5`, F1 có cải thiện nhưng vẫn ở mức thấp. Trong khi đó, với `max_depth = None`, F1 đạt mức cao nhất và xấp xỉ kết quả baseline, dao động từ khoảng `0.740` đến `0.757`.

Kết quả `ANOVA` từ mô hình `lm(f1 ~ k * max_depth)` cho thấy:

- `k`: `p-value = 0.1100`
- `max_depth`: `p-value < 2e-16`
- `k:max_depth`: `p-value = 0.3759`

Như vậy, trong phạm vi thí nghiệm Day 4, chưa có đủ bằng chứng để kết luận `k` ảnh hưởng có ý nghĩa thống kê đến `F1-score`. Ngược lại, `max_depth` có ảnh hưởng rất mạnh và có ý nghĩa thống kê đến hiệu quả mô hình. Đồng thời, chưa có bằng chứng thống kê về tương tác giữa `k` và `max_depth`.

Kết quả `TukeyHSD()` cũng củng cố nhận xét trên:

- Với yếu tố `k`, tất cả các cặp đều có `p adj > 0.05`, nên chưa có khác biệt có ý nghĩa thống kê giữa các mức `k`.
- Với yếu tố `max_depth`, cả ba cặp so sánh đều có `p adj = 0`, cho thấy các mức `3`, `5`, và `None` khác biệt có ý nghĩa thống kê.
- Với các tổ hợp `k:max_depth`, những cặp so sánh giữa nhóm `max_depth = None` và hai mức còn lại nhìn chung cho thấy khác biệt rất lớn và có ý nghĩa thống kê, trong khi các khác biệt giữa các mức `k` bên trong cùng một `max_depth` thường không có ý nghĩa thống kê.

Tổ hợp có `mean F1` cao nhất trong thí nghiệm là:

- `k = 10`
- `max_depth = None`
- `mean F1 = 0.756786`
- `CI 95%: [0.748572, 0.765000]`

Tuy nhiên, cần diễn đạt cẩn thận rằng đây là tổ hợp có `mean F1` cao nhất trong kết quả thực nghiệm, không nên kết luận ngay đây là cấu hình tốt nhất một cách tuyệt đối nếu chưa có thêm tiêu chí đánh giá hoặc thí nghiệm bổ sung.

Ba hình `crfd_interaction_plot.png`, `crfd_boxplot_by_depth.png`, và `crfd_mean_ci.png` được sử dụng để minh họa sự khác biệt về phân bố F1 giữa các mức `max_depth`, đồng thời hỗ trợ quan sát xu hướng tương tác giữa `k` và `max_depth`.
