# Cấu Trúc Dự Án Mobile (Flutter) - Binh Nguyen Wedding Event Management System

Dựa trên tham khảo mô hình phân lớp mà bạn cung cấp, dưới đây là cấu trúc kiến trúc thực tế của dự án Flutter (`bnwems-mobile-app`), được ánh xạ theo các Package và Class tương ứng. 

Dự án này áp dụng mô hình kiến trúc **Feature-First** (hoặc Module-based), chia theo từng chức năng và vai trò người dùng (Manager, Leader, Technical).

---

## 📁 Cấu trúc thư mục (Directory Structure)

```text
lib/
├── app.dart
├── main.dart
│
├── core/                           # Cốt lõi ứng dụng (Dùng chung toàn dự án)
│   ├── constants/                  # Colors, Sizes, Strings
│   ├── routes/                     # Định tuyến (App Routes)
│   ├── theme/                      # Cấu hình giao diện (Theme)
│   └── widgets/                    # Các Custom UI Component dùng chung (Dumb Widgets)
│
├── features/                       # Các tính năng chính (Chia theo domain/roles)
│   ├── auth/                       # Xác thực (Đăng nhập)
│   ├── leader/                     # Phân hệ dành cho Nhóm trưởng hiện trường
│   │   ├── dashboard/              # Màn hình chính Leader
│   │   ├── tasks/                  # Danh sách/Chi tiết công việc
│   │   ├── survey/                 # Khảo sát hiện trường
│   │   ├── handover/               # Biên bản bàn giao
│   │   ├── damage_loss/            # Báo cáo hư hỏng/mất mát
│   │   ├── change_requests/        # Yêu cầu thay đổi
│   │   ├── payment_evidence/       # Chứng từ thanh toán
│   │   ├── progress_update/        # Cập nhật tiến độ
│   │   └── warehouse_return/       # Báo cáo trả hàng kho
│   │
│   ├── technical/                  # Phân hệ dành cho Kỹ thuật viên
│   │   ├── dashboard/              # Màn hình chính Technical
│   │   ├── tasks/                  # Nhận việc, Tải minh chứng
│   │   ├── pick_list/              # Phiếu xuất kho
│   │   ├── transportation/         # Vận chuyển
│   │   ├── installation/           # Lắp đặt
│   │   ├── collection/             # Thu hồi
│   │   └── warehouse_return/       # Trả hàng
│   │
│   ├── manager/                    # Phân hệ dành cho Quản lý
│   │   ├── dashboard/              # Dashboard Manager
│   │   └── today/                  # Các tác vụ trong ngày
│   │
│   ├── orders/                     # Đơn hàng
│   ├── payments/                   # Thanh toán
│   ├── notifications/              # Thông báo
│   ├── change_requests/            # Xử lý yêu cầu thay đổi (chung)
│   ├── evidence/                   # Thư viện minh chứng
│   ├── field_progress/             # Tiến độ hiện trường
│   └── survey_review/              # Đánh giá khảo sát
│
├── models/                         # Data Models chung (OrderModel, UserModel)
│
├── providers/                      # Quản lý State/Business Logic (Ví dụ: AuthProvider)
│
├── services/                       # Tầng giao tiếp API Backend
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── order_service.dart
│
├── shared/                         # Tài nguyên chia sẻ chung (Mock data, Core Enums)
│   ├── mock/
│   └── models/                     # Các Enums/Status (OrderStatus, TaskStatus, UserRole)
│
└── utils/                          # Các hàm tiện ích (Storage, Format...)
```

---

## 🏛 Chi tiết phân bổ Code (Packages & Classes)

Bảng dưới đây giải thích rõ hơn vai trò của từng thư mục và các file cấu thành bên trong nó, tham khảo cách trình bày giống như dự án web-frontend.

### 1. Lõi Hệ Thống & Giao Diện Dùng Chung (`lib/core/` & `lib/shared/`)
Chứa các thành phần cốt lõi và UI Component độc lập, có thể tái sử dụng ở bất kỳ đâu trong toàn bộ App.

| Package / Thư mục | Các Class / File chính | Vai trò / Mô tả |
| :--- | :--- | :--- |
| `core/widgets/` | `primary_button.dart`, `custom_app_bar.dart`, `search_input.dart`, `status_chip.dart`... | Các UI Component nguyên thủy (Dumb components). Chức năng tương đương thư mục `components/ui/` trên web. |
| `core/constants/` | `app_colors.dart`, `app_sizes.dart`, `app_strings.dart` | Định nghĩa các hằng số về màu sắc, kích thước, text tĩnh. |
| `core/routes/` | `app_routes.dart` | Định nghĩa tên route và logic điều hướng màn hình. |
| `core/theme/` | `app_theme.dart` | Cấu hình ThemeData (Sáng/Tối, Typography). |
| `shared/models/` | `order_status.dart`, `user_role.dart`, `task_status.dart` | Khai báo các Enum và trạng thái dùng chung (Giống thư mục `constants/` trên web). |

### 2. Tầng Tính Năng Theo Chuyên Môn (`lib/features/`)
Chia theo chức năng chuyên biệt. Mỗi thư mục con đại diện cho một Domain hoặc Role cụ thể.

| Package / Thư mục | Các Class / File chính | Vai trò / Mô tả |
| :--- | :--- | :--- |
| `features/leader/` | `leader_dashboard_screen.dart`, `leader_task_list_screen.dart`, `leader_survey_report_screen.dart`... | Gom nhóm các màn hình độc quyền cho vai trò **Leader** (Trưởng nhóm hiện trường). Xử lý việc bàn giao, khảo sát, báo cáo mất mát. |
| `features/technical/` | `technical_dashboard_screen.dart`, `technical_pick_list_screen.dart`, `technical_installation_checklist_screen.dart`... | Nhóm màn hình của **Kỹ thuật viên**. Phục vụ quy trình xuất kho, vận chuyển, lắp đặt, tháo dỡ. |
| `features/manager/` | `manager_dashboard_screen.dart`, `manager_today_screen.dart` | Nhóm màn hình của **Quản lý** để theo dõi hoạt động vận hành trong ngày của nhân viên ngoài hiện trường. |
| `features/auth/` | `login_screen.dart` | Phân hệ Xác thực (Login). |
| `features/orders/` | `order_detail_screen.dart` | Chi tiết một đơn hàng cụ thể dành cho mobile. |
| `features/evidence/` | `evidence_gallery_screen.dart` | Thư viện minh chứng hình ảnh/video tải lên từ hiện trường. |

### 3. Tầng Giao Tiếp Dữ Liệu (`lib/services/` & `lib/utils/`)
Đảm nhiệm việc kết nối với Backend API và thao tác với phần cứng thiết bị.

| Package / Thư mục | Các Class / File chính | Vai trò / Mô tả |
| :--- | :--- | :--- |
| `services/` | `api_service.dart` | Core HTTP Client (chứa cấu hình BaseURL, bắt lỗi mạng, gắn Token header). Tương đương `api.ts` trên web. |
| `services/` | `auth_service.dart` | Logic gọi API Đăng nhập, Đăng xuất, Fetch User. |
| `services/` | `order_service.dart` | Logic gọi API liên quan đến lấy danh sách và chi tiết đơn hàng cho App. |
| `utils/` | `storage_helper.dart` | Tiện ích lưu trữ Local Storage (SharedPreferences / Secure Storage) để lưu Token và Cache. |

### 4. Quản Lý Trạng Thái & Dữ Liệu Đối Tượng (`lib/providers/` & `lib/models/`)
Xử lý Business Logic, State Management và Data Models.

| Package / Thư mục | Các Class / File chính | Vai trò / Mô tả |
| :--- | :--- | :--- |
| `providers/` | `auth_provider.dart` | Quản lý trạng thái Global (State) của phiên đăng nhập (Giống `AuthContext` bên web). |
| `models/` | `order_model.dart`, `user_model.dart` | Các Class Dart dùng để parse JSON từ API trả về thành Object (Data Models). Tương đương thư mục `types/` bên web. |
| `shared/mock/` | `mock_data.dart` | Dữ liệu giả (Dummy Data) dùng để test UI nội bộ khi chưa kết nối API Backend. |
