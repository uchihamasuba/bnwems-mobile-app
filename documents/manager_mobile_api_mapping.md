# App Manager Mobile: Ánh xạ màn hình với API Backend

Base URL cho Android emulator:

- `http://10.0.2.2:3001/api/v1`

Phạm vi:

- theo dõi nhanh
- phê duyệt nhanh
- kiểm tra minh chứng nhanh

## 1. Màn hình đăng nhập

Mục đích:

- Manager đăng nhập vào ứng dụng mobile
- khôi phục phiên đăng nhập
- đăng xuất và xóa token/session

API sử dụng:

- `POST /auth/login`
- `GET /auth/profile`
- `POST /auth/logout`
- `PUT /auth/change-password`

## 2. Mobile Dashboard

Mục đích:

- tổng quan công việc trong ngày
- các mục đang chờ duyệt
- các cảnh báo khẩn

API chính:

- `GET /dashboard/manager`
- `GET /orders?startDate=<today>&endDate=<today>`
- `GET /tasks?status=IN_PROGRESS`
- `GET /notifications?isRead=false`

API hỗ trợ hữu ích:

- `GET /orders/field-progress`
- `GET /reports/verification?orderId=<id>`

Ghi chú:

- endpoint dashboard đã trả về các số liệu tổng quan ở mức cao
- các thẻ cảnh báo khẩn có thể làm giàu thêm từ notifications và field-progress feed

## 3. Màn hình thông báo

Mục đích:

- đọc các thông báo khẩn
- đi nhanh vào màn hình duyệt hoặc chi tiết liên quan

API sử dụng:

- `GET /notifications?page=1&limit=20`
- `PUT /notifications/:id/read`

Ghi chú:

- tài liệu backend hiện mới trả notification dạng chung, chưa phân loại mạnh theo nhóm nghiệp vụ manager
- app nên tự map nội dung hoặc loại notification sang màn hình đích ở phía client

## 4. Màn hình danh sách đơn / task hôm nay

Mục đích:

- hiển thị các đơn hàng diễn ra hôm nay
- hiển thị các task đang thực hiện
- xác định ai đang phụ trách và trạng thái hiện tại

API chính:

- `GET /orders?startDate=<today>&endDate=<today>`
- `GET /tasks?status=IN_PROGRESS`
- `GET /orders/field-progress`

API hỗ trợ hữu ích:

- `GET /dashboard/manager`

Ghi chú:

- `GET /orders` cung cấp danh sách vận hành
- `GET /orders/field-progress` cho biết bước hiện trường hiện tại
- `GET /tasks` giúp hiển thị công việc đang chạy và nhân sự được phân công

## 5. Màn hình chi tiết đơn hàng

Mục đích:

- xem bản tóm tắt đơn hàng gọn trên mobile
- gồm khách hàng, ngày tổ chức, địa điểm, leader phụ trách, trạng thái thanh toán, trạng thái khảo sát, trạng thái vận hành

API chính:

- `GET /orders/:id`
- `GET /orders/:id/payments`
- `GET /reports/verification?orderId=<id>`

API hỗ trợ hữu ích:

- `GET /orders/field-progress`
- `GET /tasks?orderId=<id>`

Ghi chú:

- backend hiện chưa có endpoint tổng hợp riêng cho màn hình chi tiết đơn hàng trên mobile
- FE nên ghép dữ liệu từ order, payments, tasks và verification

## 6. Màn hình tiến độ hiện trường

Mục đích:

- theo dõi tiến trình từ xuất kho đến hoàn tất
- phát hiện bước nào đang bị trễ

API chính:

- `GET /orders/field-progress`
- `GET /tasks?orderId=<id>`

API hỗ trợ hữu ích:

- `GET /reports/verification?orderId=<id>`

Ghi chú:

- backend hiện mới trả về feed tiến độ hiện tại, chưa có timeline đầy đủ theo từng bước
- nếu cần timeline đầy đủ, backend nên bổ sung endpoint riêng như `GET /orders/:id/field-progress`

## 7. Màn hình duyệt báo cáo khảo sát

Mục đích:

- xem báo cáo khảo sát đã gửi lên
- xem ảnh khảo sát
- duyệt hoặc yêu cầu bổ sung thông tin

API chính:

- `GET /tasks/:id/survey-report`

Thiếu hụt backend hiện tại:

- chưa có endpoint để manager duyệt báo cáo khảo sát
- backend hiện chỉ hỗ trợ leader gửi báo cáo: `POST /tasks/:id/survey-report`

Đề xuất:

- thêm `PUT /tasks/:id/survey-report/review`
- request body có thể là `{ "status": "approved|needs_more_info", "reviewNote": "..." }`

## 8. Màn hình duyệt change request

Mục đích:

- duyệt, từ chối hoặc yêu cầu bổ sung thông tin cho các phát sinh hiện trường

API chính:

- `PUT /change-requests/:id/approve`

Thiếu hụt backend hiện tại:

- chưa có `GET /change-requests/:id`
- chưa có `GET /orders/:id/change-requests`

Đề xuất:

- thêm `GET /change-requests/:id`
- hoặc thêm `GET /orders/:id/change-requests`
- cho phép request body phong phú hơn khi review, ví dụ `{ "status": "approved|rejected|needs_more_info", "note": "..." }`

## 9. Màn hình xác nhận thanh toán

Mục đích:

- kiểm tra minh chứng thanh toán
- xác nhận tiền cọc hoặc thanh toán cuối

API chính:

- `GET /orders/:id/payments`
- `PUT /payments/:id/confirm`

Ghi chú:

- backend chưa có endpoint `GET /payments/:id` độc lập
- FE nên lấy danh sách payment theo order rồi chọn đúng payment cần xử lý

## 10. Màn hình thư viện minh chứng

Mục đích:

- tập hợp minh chứng khảo sát, xuất kho, lắp đặt, bàn giao, hư hỏng/mất mát, thanh toán, hoàn kho

Nguồn API có thể tận dụng ở thời điểm hiện tại:

- `GET /tasks/:id/survey-report`
- `GET /orders/:id/payments`
- `GET /reports/verification?orderId=<id>`

Thiếu hụt backend hiện tại:

- chưa có endpoint minh chứng dùng chung
- chưa có endpoint đọc chi tiết handover
- chưa có endpoint đọc chi tiết damage/loss
- chưa có endpoint tổng hợp evidence theo order

Đề xuất:

- thêm `GET /orders/:id/evidences`
- response nên nhóm minh chứng theo loại: `survey`, `checkout`, `installation`, `handover`, `damage_loss`, `payment`, `warehouse_return`

## Tổng hợp các thiếu hụt backend cho Manager Mobile

Các API còn thiếu hoặc còn yếu so với scope mobile đã chọn:

- endpoint duyệt báo cáo khảo sát
- endpoint chi tiết / danh sách change request
- endpoint chi tiết payment
- endpoint timeline đầy đủ của field-progress
- endpoint tổng hợp evidence
- endpoint tổng hợp order-detail tối ưu cho mobile
