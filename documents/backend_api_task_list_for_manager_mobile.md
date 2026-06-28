# Backend API Task List For Manager Mobile

Phuc vu giao task truc tiep cho team Backend de hoan thien App Manager Mobile.

Pham vi doi chieu:

- FE Mobile Manager: `FE_Mobile/bnwems-mobile-app/lib/features/...`
- API mapping: `FE_Mobile/bnwems-mobile-app/documents/manager_mobile_api_mapping.md`
- Audit ket noi: `FE_Mobile/bnwems-mobile-app/documents/manager_screen_connection_status.md`
- Backend hien tai: `BE/bnwems-backend-api`

Muc tieu:

- Hoan thien cac man hinh Manager Mobile dang bi block hoac dang chi chay partial.
- Chuan hoa contract FE-BE de bo MockData hoan toan.
- Giam viec FE phai ghep du lieu tu nhieu endpoint roi tu xu ly fallback.

## 1. Tong hop uu tien giao viec

| Priority | Nhom viec | Tac dong |
|---|---|---|
| High | Survey review, change request detail/list, payment detail/request list, field progress timeline, evidence aggregate, approvals queue | Block truc tiep cac manh chuc nang duyet va theo doi nghiep vu Manager |
| Medium | Dashboard summary/alerts, mobile order summary, manager notifications enrich | Nang chat luong dashboard va giam logic ghep API o FE |
| Low | Bo sung field cho orders/field-progress va tasks list | Cai thien trai nghiem va du lieu hien thi |

## 2. Task theo tung man hinh FE

### 2.1 Manager Dashboard

FE file:

- `lib/features/manager/dashboard/manager_dashboard_screen.dart`

API hien dang dung:

- `GET /dashboard/manager`
- `GET /notifications`
- `GET /orders`
- `GET /orders/field-progress`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| Medium | Bo sung alert dashboard | `GET /dashboard/manager` | Tra them `alerts[]` co noi dung dung nghiep vu Manager |
| Medium | Bo sung summary approval queue | `GET /dashboard/manager` | Tra them `pendingSurveyReports`, `pendingPayments`, `pendingChangeRequests` |
| Medium | Tach alert neu can | `GET /dashboard/manager/alerts` | Neu muon giam payload dashboard chinh |

Response goi y:

```json
{
  "data": {
    "ordersInProgress": 3,
    "tasksToday": 5,
    "pendingChangeRequests": 2,
    "pendingSurveyReports": 1,
    "pendingPayments": 2,
    "alerts": [
      {
        "type": "payment",
        "title": "Payment proof dang cho xac nhan",
        "refType": "Payment",
        "refId": "12"
      }
    ]
  }
}
```

### 2.2 Manager Today

FE file:

- `lib/features/manager/today/manager_today_screen.dart`

API hien dang dung:

- `GET /orders?startDate=&endDate=`
- `GET /tasks?status=in_progress`
- `GET /orders/field-progress`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| Low | Lam giau task list | `GET /tasks` | Tra them assignees, leader, progress info |
| Low | Lam giau field-progress feed | `GET /orders/field-progress` | Tra them `progressPercent`, `currentStep`, `delayStatus` |

### 2.3 Notifications

FE file:

- `lib/features/notifications/screens/notifications_screen.dart`

API hien dang dung:

- `GET /notifications`
- `PUT /notifications/:id/read`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| Medium | Notification enrich cho manager | `GET /notifications?scope=manager` | Tra them `priority`, `targetScreen`, `actionLabel`, `refType`, `refId` day du |

Response goi y:

```json
{
  "data": [
    {
      "notificationId": "15",
      "type": "Payment",
      "title": "Payment proof dang cho xac nhan",
      "content": "Khach da gui bien lai chuyen khoan",
      "priority": "high",
      "targetScreen": "managerPaymentConfirmation",
      "refType": "Payment",
      "refId": "12",
      "isRead": false
    }
  ]
}
```

### 2.4 Progress Overview

FE file:

- `lib/features/manager/progress/manager_progress_screen.dart`

API hien dang dung:

- `GET /orders/field-progress`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| Low | Lam giau feed tien do | `GET /orders/field-progress` | Co `currentStep`, `lastProgressNote`, `currentLeader`, `delayStatus` |

### 2.5 Field Progress Detail

FE file:

- `lib/features/field_progress/screens/field_progress_screen.dart`

Tinh trang hien tai:

- FE dang dung tam `GET /orders/:id` + `GET /tasks?orderId=` + `GET /reports/verification`
- Chua co timeline workflow theo order

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| High | Tao timeline field progress theo order | `GET /orders/:id/field-progress` | Endpoint moi, tra dung workflow step cho manager |
| High | Nhe hoa verification summary | `GET /reports/verification?orderId=` | Neu order chua xong het task thi van tra summary, khong nen fail cung |

Response goi y cho `GET /orders/:id/field-progress`:

```json
{
  "data": {
    "orderId": "3",
    "orderNumber": "ORD-0003",
    "status": "in_progress",
    "steps": [
      {
        "stepKey": "survey",
        "stepLabel": "Khao sat",
        "status": "done",
        "scheduledStart": "2026-06-29T08:00:00.000Z",
        "scheduledEnd": "2026-06-29T10:00:00.000Z",
        "actualStart": "2026-06-29T08:05:00.000Z",
        "actualEnd": "2026-06-29T09:40:00.000Z",
        "leader": {
          "userId": "8",
          "fullName": "Pham Anh Leader"
        },
        "technicians": [],
        "note": "Da gui survey report"
      }
    ]
  }
}
```

### 2.6 Survey Review

FE file:

- `lib/features/survey_review/screens/survey_review_screen.dart`

API hien dang dung:

- `GET /tasks/:id/survey-report`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| High | Them API review survey report | `PUT /tasks/:id/survey-report/review` | Manager approve/reject/request more info |
| High | Mo rong payload survey report | `GET /tasks/:id/survey-report` | Tra them cac field ky thuat va thong tin review |

Request goi y:

```json
{
  "status": "APPROVED",
  "reviewNote": "OK, co the thi cong theo phuong an nay"
}
```

Response field can co them:

- `areaSize`
- `entranceWidth`
- `installationPosition`
- `transportationCondition`
- `constructionRisk`
- `reviewStatus`
- `reviewNote`
- `reviewedBy`
- `reviewedAt`

### 2.7 Change Request Approval

FE file:

- `lib/features/change_requests/screens/change_request_approval_screen.dart`

API hien dang dung:

- `PUT /change-requests/:id/approve`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| High | API lay chi tiet change request | `GET /change-requests/:id` | Tra item, quantity, requester, reason, evidence, cost impact |
| High | API list change request theo order | `GET /orders/:id/change-requests` | De mo tu order detail hoac approvals queue |
| High | Mo rong approve API | `PUT /change-requests/:id/approve` | Ho tro note/review reason |

Request goi y:

```json
{
  "status": "APPROVED",
  "note": "Dong y bo sung do tang nhu cau anh sang loi di"
}
```

Response chi tiet can co:

- `changeRequestId`
- `orderId`
- `requestedBy`
- `requesterName`
- `reason`
- `status`
- `estimatedCost`
- `items[]`
- `evidences[]`
- `createdAt`

### 2.8 Payment Confirmation

FE file:

- `lib/features/payments/screens/payment_confirmation_screen.dart`

API hien dang dung:

- `GET /orders/:id/payments`
- `PUT /payments/:id/confirm`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| High | API payment detail | `GET /payments/:id` hoac `GET /payment-requests/:id` | Doc duoc detail khi FE chi co `paymentId` |
| High | API payment request list theo order | `GET /orders/:id/payment-requests` | Cho manager thay queue pending review |
| High | Chuan hoa contract confirm payment | `PUT /payments/:id/confirm` | Lam ro `id` la payment hay paymentRequest, chuan enum status |

Request goi y:

```json
{
  "status": "CONFIRMED",
  "reviewNote": "Da doi chieu bien lai",
  "evidenceUrl": "https://..."
}
```

Response detail can co:

- `paymentId`
- `paymentRequestId`
- `orderId`
- `paymentType`
- `amount`
- `paymentMethod`
- `status`
- `submittedBy`
- `submittedAt`
- `confirmedBy`
- `confirmedAt`
- `evidences[]`
- `reviewNote`

### 2.9 Evidence Gallery

FE file:

- `lib/features/evidence/screens/evidence_gallery_screen.dart`

Tinh trang hien tai:

- FE dang ghep tam survey evidence + payment evidence
- Khong mo duoc theo order neu khong co `orderId`

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| High | API tong hop evidence theo order | `GET /orders/:id/evidences` | Gom evidence cho toan bo nghiep vu manager can xem |

Response goi y:

```json
{
  "data": {
    "orderId": "3",
    "groups": {
      "survey": [],
      "checkout": [],
      "installation": [],
      "handover": [],
      "damageLoss": [],
      "payment": [],
      "warehouseReturn": [],
      "settlement": []
    }
  }
}
```

### 2.10 Order Detail

FE file:

- `lib/features/orders/screens/order_detail_screen.dart`

Tinh trang hien tai:

- FE dang ghep tu nhieu API
- Co nhieu fallback va manh du lieu partial

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| Medium | API mobile order summary | `GET /orders/:id/mobile-summary` | Gom toan bo summary can cho mobile manager |
| High | API change request theo order | `GET /orders/:id/change-requests` | De mo dung phat sinh that tu order detail |
| High | API evidence theo order | `GET /orders/:id/evidences` | De preview minh chung that tren order detail |

Response `mobile-summary` nen co:

- `order`
- `customer`
- `paymentSummary`
- `latestSurvey`
- `latestProgress`
- `pendingChangeRequests`
- `verificationSummary`
- `evidencePreview`

### 2.11 Manager Approvals

FE file:

- `lib/features/manager/approvals/manager_approvals_screen.dart`

Tinh trang hien tai:

- Man nay moi co count + notifications
- Chua co approval queue that

Task Backend can lam:

| Priority | Task | Endpoint | Yeu cau |
|---|---|---|---|
| High | API approvals queue tong hop | `GET /manager/approvals` | Tra danh sach survey approvals, change requests, payment requests |
| High | API list survey approvals | `GET /survey-reports/pending` hoac endpoint tuong duong | De FE khong phai scan notification |

Response goi y:

```json
{
  "data": {
    "surveyReports": [],
    "changeRequests": [],
    "paymentRequests": []
  }
}
```

Moi item nen co:

- `id`
- `type`
- `title`
- `status`
- `orderId`
- `submittedBy`
- `submittedAt`
- `priority`

## 3. Danh sach API Backend can bo sung

### Priority High

- `GET /orders/:id/field-progress`
- `PUT /tasks/:id/survey-report/review`
- `GET /change-requests/:id`
- `GET /orders/:id/change-requests`
- `GET /payments/:id` hoac `GET /payment-requests/:id`
- `GET /orders/:id/payment-requests`
- `PUT /payments/:id/confirm` can chuan hoa contract
- `GET /orders/:id/evidences`
- `GET /manager/approvals`
- `GET /survey-reports/pending` hoac endpoint tuong duong

### Priority Medium

- Mo rong `GET /dashboard/manager`
- `GET /dashboard/manager/alerts`
- `GET /orders/:id/mobile-summary`
- Mo rong `GET /notifications?scope=manager`

### Priority Low

- Mo rong `GET /orders/field-progress`
- Mo rong `GET /tasks`

## 4. Danh sach contract can chuan hoa giua FE va BE

| Chu de | Van de hien tai | Viec Backend can chot |
|---|---|---|
| Payment confirm | Chua ro `id` la `paymentId` hay `paymentRequestId` | Chot 1 contract duy nhat va cap nhat response list/detail theo contract do |
| Payment status | FE manager dang can cac trang thai review ro rang | Chot enum vi du `PENDING_REVIEW`, `CONFIRMED`, `REJECTED`, `NEEDS_MORE_INFO` |
| Survey review | Chua co action API | Chot enum review va field review note |
| Change request review | Hien approve API con qua it field | Chot request body co `status`, `note` |
| Notifications | Thieu `priority`, `targetScreen` | Chot payload notification cho manager mobile |
| Field progress | Feed tong hop qua mong | Chot response workflow step theo order |

## 5. De xuat thu tu implement cho team Backend

### Sprint 1

- `GET /orders/:id/field-progress`
- `PUT /tasks/:id/survey-report/review`
- `GET /change-requests/:id`
- `GET /orders/:id/change-requests`
- `GET /payments/:id` hoac `GET /payment-requests/:id`
- `GET /orders/:id/payment-requests`

### Sprint 2

- `GET /orders/:id/evidences`
- `GET /manager/approvals`
- `GET /survey-reports/pending`
- Chuan hoa `PUT /payments/:id/confirm`

### Sprint 3

- `GET /orders/:id/mobile-summary`
- Mo rong `GET /dashboard/manager`
- Mo rong `GET /notifications`
- Mo rong `GET /orders/field-progress`
- Mo rong `GET /tasks`

## 6. Ket luan

- Hien tai Manager Mobile da bo MockData o nhieu man hinh chinh, nhung van con bi block boi cac API review/detail/aggregate.
- Nhom task Backend uu tien cao nhat la cac API approval va detail theo order.
- Neu team Backend hoan thanh nhom `High`, FE Manager se co the chay that cho phan lon workflow quan trong: theo doi tien do, duyet khao sat, duyet phat sinh, xac nhan thanh toan, xem minh chung.
