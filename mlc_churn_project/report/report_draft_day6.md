# Báo cáo nháp Day 6 - Project `mlc_churn`

## 1. Giới thiệu

Bài toán của project là dự đoán khách hàng có rời mạng hay không, với biến mục tiêu là `churn`. Trong đó, `churn = yes` được chọn làm positive class vì đây là nhóm khách hàng doanh nghiệp cần quan tâm nhất trong bài toán giữ chân khách hàng.

Về mặt thực tiễn, dự đoán churn có ý nghĩa quan trọng trong quản trị quan hệ khách hàng. Nếu doanh nghiệp có thể nhận diện sớm những khách hàng có nguy cơ rời mạng, doanh nghiệp có thể chủ động xây dựng các chương trình chăm sóc, ưu đãi hoặc cải thiện chất lượng dịch vụ nhằm giảm tỷ lệ rời mạng.

Trong nghiên cứu này, mô hình được sử dụng là `RandomForestClassifier`. Đây là mô hình học máy phù hợp với dữ liệu gồm cả biến số và biến phân loại, đồng thời có khả năng mô hình hóa các quan hệ phi tuyến. Độ đo đánh giá chính được sử dụng là `F1-score` với positive class = `yes`, thay vì accuracy, do bộ dữ liệu bị mất cân bằng lớp.

## 2. Mô tả dữ liệu

Bộ dữ liệu `mlc_churn.csv` gồm `5000` quan sát và `20` biến. Mỗi dòng dữ liệu tương ứng với một khách hàng. Các biến trong bộ dữ liệu có thể chia thành các nhóm chính như sau:

- Thông tin tài khoản, ví dụ: `account_length`, `state`, `area_code`.
- Thông tin gói dịch vụ, ví dụ: `international_plan`, `voice_mail_plan`.
- Thông tin sử dụng cuộc gọi, ví dụ: `total_day_minutes`, `total_eve_minutes`, `total_night_minutes`, `total_intl_minutes`, cùng các biến số cuộc gọi tương ứng.
- Số lần liên hệ chăm sóc khách hàng, ví dụ: `number_customer_service_calls`.
- Biến mục tiêu `churn`.

Biến mục tiêu `churn` nhận hai giá trị `yes` và `no`, trong đó `yes` biểu thị khách hàng rời mạng, còn `no` biểu thị khách hàng không rời mạng.

Kết quả phân tích phân bố lớp cho thấy:

- `churn = yes`: `707` quan sát, chiếm `14.14%`
- `churn = no`: `4293` quan sát, chiếm `85.86%`

Như vậy, bộ dữ liệu bị mất cân bằng lớp, với lớp `yes` là lớp thiểu số.

## 3. Phương pháp

### 3.1. Tiền xử lý và lựa chọn biến

Kết quả kiểm tra dữ liệu cho thấy bộ dữ liệu không có missing value. Trong bước tiền xử lý:

- Biến mục tiêu được mã hóa theo quy ước `yes -> 1`, `no -> 0`.
- Các biến phân loại gồm `state`, `area_code`, `international_plan`, và `voice_mail_plan` được mã hóa bằng `OneHotEncoder(handle_unknown="ignore")`.
- Các biến số được giữ nguyên, không thực hiện scaling vì Random Forest không yêu cầu chuẩn hóa dữ liệu đầu vào.

Trong Day 2, phân tích tương quan cho thấy các cặp biến `minutes-charge` có tương quan gần như tuyệt đối:

- `total_day_minutes` với `total_day_charge`
- `total_eve_minutes` với `total_eve_charge`
- `total_night_minutes` với `total_night_charge`
- `total_intl_minutes` với `total_intl_charge`

Do đó, bốn biến sau đã được loại khỏi mô hình:

- `total_day_charge`
- `total_eve_charge`
- `total_night_charge`
- `total_intl_charge`

Việc loại các biến `charge` là hợp lý vì các biến này trùng lặp mạnh với thông tin từ các biến `minutes`, trong khi về mặt thực tiễn cước phí được tính trực tiếp từ thời lượng gọi.

### 3.2. Mô hình baseline

Mô hình baseline được xây dựng bằng `RandomForestClassifier` với:

- `random_state = 1234`
- `max_depth = None`
- chia dữ liệu train/test theo tỷ lệ `80/20`
- sử dụng `stratify = y`

Mục tiêu của baseline là kiểm tra pipeline tiền xử lý và cung cấp một mốc tham chiếu ban đầu trước khi thực hiện các thí nghiệm CRD và CRFD.

### 3.3. Thiết kế thí nghiệm CRD

Thí nghiệm `CRD` được sử dụng để đánh giá ảnh hưởng của số fold `k` đến `F1-score` của mô hình Random Forest. Trong thí nghiệm này:

- Yếu tố nghiên cứu: `k`
- Các mức của `k`: `3`, `5`, `10`
- `repeat = 10`
- sử dụng `StratifiedKFold`
- `max_depth = None`
- `random_state = 1234`

Với mỗi mức `k`, mỗi lần lặp sinh ra nhiều fold, và mỗi fold cho ra một giá trị `F1-score`. Tổng số quan sát thí nghiệm là `180`, gồm:

- `30` quan sát với `k = 3`
- `50` quan sát với `k = 5`
- `100` quan sát với `k = 10`

Kết quả chi tiết được lưu trong `results/crd_results.csv`. Phần phân tích trong RStudio sử dụng:

- `leveneTest()`
- `lm()`
- `ANOVA`
- `TukeyHSD()`
- `boxplot`
- `mean confidence interval plot`

### 3.4. Thiết kế thí nghiệm CRFD

Thí nghiệm `CRFD` được thiết kế để đánh giá đồng thời ảnh hưởng của hai yếu tố đến `F1-score`:

- Yếu tố 1: `k = 3, 5, 10`
- Yếu tố 2: `max_depth = 3, 5, None`
- `repeat = 10`
- sử dụng `StratifiedKFold`
- `random_state = 1234`

Tổng số quan sát thí nghiệm là `540`. Kết quả được lưu trong `results/crfd_results.csv`. Phần phân tích trong RStudio sử dụng:

- `lm(f1 ~ k * max_depth)`
- `ANOVA`
- `TukeyHSD()`
- `interaction plot`
- `boxplot`
- `mean confidence interval plot`

Mục tiêu của CRFD là trả lời ba câu hỏi:

1. `k` có ảnh hưởng đến `F1-score` hay không?
2. `max_depth` có ảnh hưởng đến `F1-score` hay không?
3. Có tương tác giữa `k` và `max_depth` hay không?

## 4. Kết quả

### 4.1. Kết quả baseline

Kết quả baseline cho thấy:

- `F1-score` với positive class = `yes`: `0.758621`
- Precision lớp `yes`: `0.97`
- Recall lớp `yes`: `0.62`
- F1 lớp `yes`: xấp xỉ `0.76`

Ma trận nhầm lẫn:

```text
[[856, 3],
 [53, 88]]
```

Kết quả này cho thấy mô hình có precision rất cao khi dự đoán khách hàng sẽ rời mạng, tức là nếu mô hình dự đoán `yes` thì thường là đúng. Tuy nhiên, recall của lớp `yes` mới ở mức `0.62`, nghĩa là mô hình vẫn bỏ sót một phần khách hàng rời mạng.

### 4.2. Phân tích kết quả thí nghiệm CRD

#### Mục tiêu thí nghiệm

Mục tiêu của CRD là kiểm tra xem số fold `k` trong stratified cross-validation có ảnh hưởng đến `F1-score` của mô hình hay không. Ba mức được khảo sát là `k = 3`, `5`, và `10`, với `10` lần lặp cho mỗi mức. Mỗi fold tạo ra một giá trị `F1-score`, và toàn bộ thí nghiệm tạo ra `180` quan sát.

#### Thống kê mô tả

Bảng thống kê mô tả theo từng mức `k` như sau:

| k | n | mean F1 | sd | se | CI lower | CI upper |
|---|---:|---:|---:|---:|---:|---:|
| 3 | 30 | 0.740299 | 0.022036 | 0.004023 | 0.732071 | 0.748527 |
| 5 | 50 | 0.752170 | 0.033807 | 0.004781 | 0.742563 | 0.761778 |
| 10 | 100 | 0.756786 | 0.041396 | 0.004140 | 0.748572 | 0.765000 |

Về mặt mô tả, `k = 10` có `F1-score` trung bình cao nhất, còn `k = 3` có `F1-score` trung bình thấp nhất. Tuy nhiên, mức chênh lệch giữa các giá trị trung bình là khá nhỏ, chỉ khoảng `0.0165` giữa mức cao nhất và thấp nhất. Các khoảng tin cậy 95% của ba nhóm chồng lấn đáng kể, cho thấy khác biệt về mean F1 giữa các mức `k` không lớn về mặt thực tiễn.

Độ lệch chuẩn có xu hướng tăng khi `k` tăng, từ `0.0220` ở `k = 3` lên `0.0414` ở `k = 10`. Điều này gợi ý rằng độ phân tán của kết quả đánh giá có thể khác nhau giữa các mức `k`.

#### Kiểm định Levene

Kiểm định `leveneTest(f1 ~ k)` cho kết quả `p-value = 0.0004759 < 0.05`. Như vậy, phương sai `F1-score` giữa các nhóm `k` khác nhau có ý nghĩa thống kê. Kết quả này cho thấy độ ổn định của `F1-score` không hoàn toàn giống nhau giữa các lựa chọn `k`.

#### ANOVA / lm()

Kết quả `ANOVA` cho mô hình `lm(f1 ~ k)` cho `p-value = 0.1008`, lớn hơn `0.05`. Vì vậy, chưa có bằng chứng thống kê cho thấy `k` ảnh hưởng đến `F1-score` của mô hình Random Forest trong phạm vi thí nghiệm này.

#### TukeyHSD

Kết quả `TukeyHSD()` cho thấy không có cặp mức `k` nào khác biệt có ý nghĩa thống kê:

- `5 - 3`: `p adj = 0.3448`
- `10 - 3`: `p adj = 0.0825`
- `10 - 5`: `p adj = 0.7495`

Tất cả các giá trị `p adj` đều lớn hơn `0.05`, nên chưa có bằng chứng thống kê về khác biệt cặp giữa các mức `k`.

#### Nhận xét biểu đồ

Từ `boxplot` và biểu đồ `mean CI`, có thể nhận xét rằng nhóm `k = 10` có mean và trung vị nhỉnh hơn hai nhóm còn lại, trong khi `k = 3` có mean thấp nhất. Tuy nhiên, các khoảng tin cậy chồng lấn rõ rệt, và phân bố giữa các nhóm không tách biệt mạnh. Điều này phù hợp với kết quả ANOVA và TukeyHSD: có xu hướng tăng nhẹ về mean F1 khi tăng `k`, nhưng chưa đủ mạnh để kết luận có khác biệt có ý nghĩa thống kê.

[CHÈN HÌNH `crd_boxplot.png`]

[CHÈN HÌNH `crd_mean_ci.png`]

#### Kết luận CRD

Trong thí nghiệm CRD, chưa có bằng chứng thống kê cho thấy số fold `k` ảnh hưởng đến `F1-score` của mô hình Random Forest. Hiệu năng của mô hình nhìn chung khá ổn định giữa các mức `k = 3`, `5`, và `10`. Nếu cần lựa chọn một mức để tiếp tục cân nhắc, `k = 10` là mức có `F1-score` trung bình cao nhất trong thí nghiệm, nhưng mức chênh lệch không lớn và chưa được ủng hộ bởi kiểm định thống kê.

### 4.3. Phân tích kết quả thí nghiệm CRFD

#### Mục tiêu thí nghiệm

Mục tiêu của CRFD là đánh giá đồng thời ảnh hưởng của `k` và `max_depth` đến `F1-score`, đồng thời kiểm tra xem có tương tác giữa hai yếu tố này hay không.

#### Thống kê mô tả

Bảng thống kê mô tả theo từng tổ hợp `k` và `max_depth` như sau:

| k | max_depth | n | mean F1 | sd | se | CI lower | CI upper |
|---|---|---:|---:|---:|---:|---:|---:|
| 3 | 3 | 30 | 0.002254 | 0.003802 | 0.000694 | 0.000834 | 0.003673 |
| 3 | 5 | 30 | 0.064496 | 0.024049 | 0.004391 | 0.055516 | 0.073476 |
| 3 | None | 30 | 0.740299 | 0.022036 | 0.004023 | 0.732071 | 0.748527 |
| 5 | 3 | 50 | 0.001406 | 0.004262 | 0.000603 | 0.000195 | 0.002618 |
| 5 | 5 | 50 | 0.069920 | 0.030595 | 0.004327 | 0.061225 | 0.078615 |
| 5 | None | 50 | 0.752170 | 0.033807 | 0.004781 | 0.742563 | 0.761778 |
| 10 | 3 | 100 | 0.000556 | 0.003911 | 0.000391 | -0.000220 | 0.001333 |
| 10 | 5 | 100 | 0.072578 | 0.042495 | 0.004250 | 0.064149 | 0.081008 |
| 10 | None | 100 | 0.756786 | 0.041396 | 0.004140 | 0.748572 | 0.765000 |

Tổ hợp có `F1-score` trung bình cao nhất trong thí nghiệm là `k = 10`, `max_depth = None`, với mean F1 bằng `0.756786`. Tổ hợp thấp nhất là `k = 10`, `max_depth = 3`, với mean F1 bằng `0.000556`. Chênh lệch này cho thấy `max_depth` có ảnh hưởng thực tiễn rất lớn đến hiệu năng mô hình.

Xét theo xu hướng chung:

- `max_depth = None` luôn cho kết quả cao nhất ở cả ba mức `k`
- `max_depth = 5` cho kết quả trung gian
- `max_depth = 3` cho kết quả rất thấp, gần như bằng `0`

Xét theo yếu tố `k`, mean F1 có xu hướng tăng nhẹ khi `k` tăng, nhưng mức tăng nhỏ hơn nhiều so với khác biệt giữa các mức `max_depth`. Các khoảng tin cậy của các nhóm cùng `max_depth = None` chồng lấn khá nhiều, trong khi khoảng cách giữa nhóm `None` với nhóm `5` và `3` là rất rõ rệt.

#### ANOVA / lm(f1 ~ k * max_depth)

Kết quả `ANOVA` cho mô hình `lm(f1 ~ k * max_depth)` cho thấy:

- `k`: `p-value = 0.1100`
- `max_depth`: `p-value < 2e-16`
- `k:max_depth`: `p-value = 0.3759`

Từ đó có thể kết luận:

- Chưa có bằng chứng thống kê cho thấy `k` ảnh hưởng đến `F1-score`.
- Yếu tố `max_depth` có ảnh hưởng có ý nghĩa thống kê đến `F1-score`.
- Chưa có bằng chứng thống kê về tương tác giữa `k` và `max_depth`.

#### TukeyHSD

Kết quả `TukeyHSD()` cho yếu tố `k` cho thấy không có cặp nào khác biệt có ý nghĩa thống kê:

- `5 - 3`: `p adj = 0.3616`
- `10 - 3`: `p adj = 0.0905`
- `10 - 5`: `p adj = 0.7581`

Đối với yếu tố `max_depth`, cả ba cặp đều khác biệt có ý nghĩa thống kê:

- `5 - 3`: `p adj = 0`
- `None - 3`: `p adj = 0`
- `None - 5`: `p adj = 0`

Đối với phần tương tác, các khác biệt quan trọng chủ yếu nằm ở việc các tổ hợp có `max_depth = None` vượt trội rõ so với các tổ hợp có `max_depth = 3` hoặc `5`. Trong khi đó, khác biệt giữa các mức `k` bên trong cùng một mức `max_depth` nhìn chung không có ý nghĩa thống kê.

#### Interaction plot

Dựa trên interaction plot, các đường theo `max_depth` có một số khác biệt về độ dốc, nhưng nhìn chung không có dấu hiệu cắt nhau rõ rệt. Điều này cho thấy tương tác giữa `k` và `max_depth` là yếu hoặc không rõ. Nhận xét trực quan này phù hợp với kết quả kiểm định thống kê, khi `p-value` của `k:max_depth` bằng `0.3759`, tức là chưa có bằng chứng thống kê về tương tác giữa hai yếu tố.

[CHÈN HÌNH `crfd_interaction_plot.png`]

[CHÈN HÌNH `crfd_boxplot_by_depth.png`]

[CHÈN HÌNH `crfd_mean_ci.png`]

#### Kết luận CRFD

Trong thí nghiệm CRFD, yếu tố ảnh hưởng mạnh nhất đến `F1-score` là `max_depth`. Cụ thể, `max_depth = None` cho kết quả cao hơn rõ rệt so với `max_depth = 5` và `max_depth = 3`, đồng thời khác biệt này có ý nghĩa thống kê. Ngược lại, chưa có bằng chứng thống kê cho thấy `k` ảnh hưởng đến `F1-score`, và cũng chưa có bằng chứng thống kê về tương tác giữa `k` và `max_depth`.

Tổ hợp có `F1-score` trung bình cao nhất trong thí nghiệm là `k = 10`, `max_depth = None`. Tuy nhiên, nên diễn đạt đây là tổ hợp có `F1-score` trung bình cao nhất trong phạm vi thí nghiệm, thay vì khẳng định tuyệt đối là cấu hình tốt nhất.

## 5. Thảo luận

Việc sử dụng `F1-score` thay vì accuracy là phù hợp với bản chất của bài toán. Do lớp `churn = yes` chỉ chiếm `14.14%`, nếu chỉ dùng accuracy thì mô hình có thể đạt kết quả cao chỉ bằng cách ưu tiên dự đoán lớp `no`. Trong khi đó, `F1-score` phản ánh đồng thời precision và recall của lớp `yes`, nên phù hợp hơn với mục tiêu nhận diện khách hàng có nguy cơ rời mạng.

Việc sử dụng `stratified` trong train/test split và trong `StratifiedKFold` là cần thiết. Khi dữ liệu mất cân bằng lớp, chia dữ liệu không phân tầng có thể làm lệch tỷ lệ `yes/no` giữa các tập con, từ đó khiến kết quả đánh giá thiếu ổn định hoặc thiếu công bằng giữa các lần lặp.

Kết quả CRD cho thấy thay đổi số fold `k` không làm thay đổi đáng kể `F1-score` của mô hình. Điều này gợi ý rằng đánh giá mô hình tương đối ổn định theo `k`, miễn là vẫn dùng stratified fold và lặp đủ số lần. Tuy nhiên, kiểm định Levene cho thấy phương sai giữa các nhóm `k` khác nhau có ý nghĩa thống kê, nghĩa là độ ổn định của kết quả có thể khác nhau phần nào giữa các lựa chọn `k`.

Kết quả CRFD cho thấy `max_depth` là yếu tố ảnh hưởng mạnh đến khả năng học của Random Forest. Khi `max_depth` bị giới hạn ở `3`, mô hình gần như không học được tín hiệu cần thiết để phát hiện lớp `yes`. Khi tăng lên `5`, hiệu năng có cải thiện nhưng vẫn thấp. Chỉ khi để `max_depth = None`, mô hình mới đạt hiệu năng tốt và gần với mức baseline. Điều này cho thấy trong bài toán churn hiện tại, mô hình cần độ linh hoạt đủ lớn để khai thác các quan hệ phức tạp trong dữ liệu.

Việc loại bốn biến `charge` là hợp lý cả về mặt thống kê và thực tiễn. Các biến này gần như là bản sao tuyến tính của các biến `minutes` tương ứng, nên giữ lại sẽ làm tăng dư thừa thông tin mà không mang thêm giá trị diễn giải đáng kể.

Một số hạn chế của nghiên cứu cần được ghi nhận. Thứ nhất, nghiên cứu mới tập trung vào một mô hình là Random Forest và một số mức tham số giới hạn. Thứ hai, độ đo đánh giá chính mới là `F1-score`, chưa mở rộng sang các chỉ số khác như recall của lớp `yes`, PR-AUC hoặc ROC-AUC. Thứ ba, mặc dù có repeated stratified k-fold, số mức tham số khảo sát vẫn còn tương đối ít.

Nếu có thêm thời gian, có thể mở rộng nghiên cứu theo các hướng sau:

- khảo sát thêm các siêu tham số khác của Random Forest như `n_estimators`, `min_samples_leaf`, `max_features`
- bổ sung các phương pháp xử lý mất cân bằng lớp như `class_weight`, over-sampling hoặc under-sampling
- so sánh với các mô hình khác như Logistic Regression, XGBoost hoặc LightGBM
- đánh giá thêm các độ đo khác để hỗ trợ lựa chọn mô hình toàn diện hơn

## 6. Kết luận

Mục tiêu của project là xây dựng mô hình dự đoán khách hàng rời mạng, với positive class là `churn = yes`, trên bộ dữ liệu gồm `5000` quan sát và `20` biến. Sau bước phân tích dữ liệu và lựa chọn biến, bốn biến `charge` đã được loại bỏ do tương quan gần như tuyệt đối với các biến `minutes` tương ứng.

Mô hình Random Forest baseline với `random_state = 1234`, `max_depth = None`, và chia train/test `80/20` có `stratify` đạt `F1-score = 0.758621` cho lớp `yes`. Kết quả này cho thấy pipeline mô hình hoạt động tốt, nhưng recall của lớp `yes` vẫn còn dư địa cải thiện.

Trong thí nghiệm CRD, chưa có bằng chứng thống kê cho thấy số fold `k` ảnh hưởng đến `F1-score`, mặc dù `k = 10` là mức có `F1-score` trung bình cao nhất trong ba mức khảo sát. Điều này cho thấy hiệu năng mô hình tương đối ổn định theo lựa chọn `k`.

Trong thí nghiệm CRFD, `max_depth` là yếu tố có ảnh hưởng có ý nghĩa thống kê đến `F1-score`, trong khi `k` và tương tác `k:max_depth` chưa cho thấy ý nghĩa thống kê. Kết quả mô tả và các kiểm định đều cho thấy `max_depth = None` vượt trội hơn rõ rệt so với `max_depth = 5` và `max_depth = 3`.

Tổ hợp có `F1-score` trung bình cao nhất trong thí nghiệm là `k = 10`, `max_depth = None`. Dựa trên toàn bộ kết quả thực nghiệm, có thể xem `max_depth = None` là lựa chọn phù hợp hơn cho bài toán này, còn yếu tố `k` có thể được chọn linh hoạt giữa các mức khảo sát do chưa có khác biệt có ý nghĩa thống kê rõ ràng.

## Checklist Day 6

- [x] Đã có nhận xét CRD dựa trên mean, CI, Levene, ANOVA, Tukey.
- [x] Đã có nhận xét CRFD dựa trên mean, CI, ANOVA, Tukey, interaction plot.
- [x] Đã chèn hoặc đánh dấu vị trí chèn hình CRD.
- [x] Đã chèn hoặc đánh dấu vị trí chèn hình CRFD.
- [x] Đã viết phần thảo luận.
- [x] Đã viết phần kết luận.
- [x] Đã kiểm tra positive class = yes.
- [x] Đã kiểm tra random seed = 1234.
- [x] Đã kiểm tra báo cáo không bịa p-value.
- [x] Đã liệt kê đúng 2 file cần nộp: `crd_results.csv` và `crfd_results.csv`.
