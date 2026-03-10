# Qarz Daftar iOS

Qarz Daftar bu iOS uchun offline qarz boshqaruv ilovasi. Ilova foydalanuvchiga kimdan qarz olgani, kimga qarz bergani, qancha to'lagani va qancha qolganini aniq yuritishda yordam beradi.

## Asosiy imkoniyatlar

### 1) Qarzlarni boshqarish
- Yangi qarz qo'shish: `Men qarz oldim` yoki `Men qarz berdim`
- Har bir yozuv uchun: summa, valyuta, sana, due date, izoh, telefon, kategoriya
- Qarzni tahrirlash, o'chirish va yopish
- Mavjud qarzga yana summa qo'shish (`Add to debt`)

### 2) To'lovlar
- Qisman yoki to'liq to'lov qo'shish
- To'lov summasi qolgan summadan oshib ketmasligi validatsiyasi
- To'lovlar tarixini ko'rish
- Qolgan summa avtomatik qayta hisoblanadi

### 3) Asosiy tab (Dashboard)
- Qidiruv (`Search`)
- Filter: `Hammasi`, `Qarz olganlar`, `Qarz berganlar`, `Aktivlar`, `Yopilganlar`
- Sort: `Sana`, `Summa`, `Ism`
- Summary kartalar: `Jami qarz olgan`, `Jami qarz bergan`, `Jami to'langan`, `Jami qolgan`

### 4) Statistika tab
- Qarz turi bo'yicha bar chart
- Qarz statusi bo'yicha bar chart
- Oylik to'lovlar bo'yicha line/area chart

### 5) Profil va sozlamalar
- Avatar, ism va telefonni modal orqali tahrirlash
- Telefon avtomatik formatlanadi: `+998 93 216 61 20`
- Til: `O'zbekcha`, `Русский`, `English`
- Mavzu: `Kunduzgi`, `Tungi`, `Tizim`
- Valyuta: `UZS`, `USD`, `EUR`, `RUB`
- Ilova versiyasi Profil pastida ko'rsatiladi

### 6) Xavfsizlik va bildirishnomalar
- 4 xonali PIN bilan kirish
- Face ID / Touch ID bilan ochish
- Due date kiritilgan qarzlar uchun local reminder notification
- Ilovaga birinchi kirishda notification ruxsati so'raladi

## Ishlatilgan texnologiyalar

| Qatlam | Texnologiya | Vazifa |
|---|---|---|
| UI | `SwiftUI` | Ekranlar, tablar, formalar |
| Charts | `Charts` | Statistika diagrammalari |
| State | `ObservableObject` (`AppStore`) | Markaziy state va business logic |
| Persistence | `JSON` (`Application Support`) | Offline ma'lumot saqlash |
| Notifications | `UserNotifications` | Due date reminderlar |
| Security | `Keychain` + `CryptoKit` | PIN hash saqlash |
| Biometric | `LocalAuthentication` | Face ID / Touch ID |
| Media | `PhotosUI` | Avatar tanlash |

## Asosiy formulalar

- `Qolgan summa = Umumiy summa - To'langan summa`
- `Aktiv qarz = qolgan summa > 0`
- `Yopilgan qarz = qolgan summa = 0`
- `Jami to'langan = barcha to'lovlar summasi`
- `Jami qarz olgan = borrowed turidagi yozuvlar yig'indisi`
- `Jami qarz bergan = lent turidagi yozuvlar yig'indisi`

## Ma'lumotlar saqlanishi

- Asosiy ma'lumotlar: `Application Support/qarz-daftar.json`
- Avatar fayllari: `Application Support/avatars/`
- PIN kodi: `Keychain` ichida SHA-256 hash ko'rinishida

## Loyiha strukturasi

```text
Qarz Daftar/
  Qarz Daftar/
    Models/
    Services/
    Store/
    Utils/
    Views/
      Main/
      Statistics/
      Profile/
      Common/
```

## Ishga tushirish

### Talablar
- `Xcode 15+`
- `iOS 16.0+`

### Qadamlar
1. Repository'ni clone qiling.
2. `Qarz Daftar.xcodeproj` ni Xcode'da oching.
3. iPhone simulator yoki real device tanlang.
4. `Run` (`Cmd + R`) ni bosing.

## Hozirgi holat

- 3 ta tab: `Asosiy`, `Statistika`, `Profil`
- Qarz CRUD + to'lovlar tarixi
- Qarz summasini keyin oshirish funksiyasi
- Diagrammalar bilan statistika
- Reminder notificationlar
- PIN va biometrik himoya
- To'liq offline ishlash
