# Finova Data Analytics

Proyek analisis data untuk mengeksplorasi perilaku pelanggan, transaksi, produk, dan revenue pada data sintetis Finova. Analisis dikerjakan dengan SQL dan Python, lalu dapat divisualisasikan di Looker Studio.

> **Catatan:** seluruh data dalam proyek ini dibuat secara sintetis untuk keperluan portofolio dan pembelajaran.

## Dashboard

Placeholder dashboard:

![Finova dashboard placeholder](docs/dashboard/dashboard.jpg)

Ganti file `docs/dashboard/dashboard.jpg` dengan screenshot Looker Studio milikmu saat sudah siap. Gunakan nama dan lokasi file yang sama agar tampilan di GitHub otomatis diperbarui.

Panduan singkat penggantian gambar tersedia di [docs/dashboard/README.md](docs/dashboard/README.md).

## Tujuan Analisis

- Memvalidasi kualitas dan konsistensi data.
- Menganalisis profil dan aktivitas pelanggan.
- Mengukur volume serta nilai transaksi.
- Mengidentifikasi performa produk dan kontribusi revenue.
- Menemukan peluang bisnis berdasarkan frekuensi dan nilai pelanggan.

## Struktur Proyek

```text
.
├── data/       # Dataset CSV sintetis
├── docs/       # Dokumentasi dan screenshot dashboard
├── python/     # Notebook analisis Python
├── sql/        # Query analisis MySQL
├── check_finova.py      # Pemeriksaan kualitas data
└── generate_finova.py   # Generator dataset sintetis
```

## Dataset

| File | Isi | Jumlah baris |
| --- | --- | ---: |
| `tb_cust.csv` | Profil pelanggan | 10.000 |
| `tb_transaction.csv` | Data transaksi | 200.000 |
| `tb_transaction_product.csv` | Produk pada tiap transaksi | 200.000 |
| `tb_transaction_fees.csv` | Biaya dan revenue transaksi | 200.000 |

Periode transaksi: **1 Januari 2025 – 30 Juni 2026**.

## Cara Menjalankan

### 1. Siapkan environment Python

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Validasi data

```bash
python3 check_finova.py
```

### 3. Jalankan notebook

```bash
jupyter notebook
```

Jalankan notebook secara berurutan dari `01_data_loading.ipynb` sampai `06_business_insight.ipynb`.

### 4. Jalankan query SQL

Impor empat file CSV pada folder `data/` ke database MySQL bernama `finova`, dengan nama tabel yang sama seperti nama file tanpa ekstensi. Lalu jalankan query secara berurutan di folder `sql/`, dari validasi data hingga analisis peluang bisnis.

## Cakupan Analisis SQL

| Query | Fokus |
| --- | --- |
| `01_data_validation.sql` | Kualitas data dan referential integrity |
| `02_customer_analysis.sql` | Segmentasi dan aktivitas pelanggan |
| `03_transaction_analysis.sql` | Nilai dan pola transaksi |
| `04_frequency_analysis.sql` | Frekuensi transaksi pelanggan |
| `05_product_analysis.sql` | Performa produk |
| `06_revenue_analysis.sql` | Revenue dan kontribusi pelanggan |
| `07_segment_product_analysis.sql` | Preferensi produk tiap segmen |
| `08_customer_value_analysis.sql` | Nilai dan konsentrasi revenue pelanggan |
| `09_business_opportunity_analysis.sql` | Peluang bisnis berbasis perilaku pelanggan |

## Konfigurasi Lokal

Kredensial database tidak disimpan di repository. Untuk SQLTools VS Code, salin `.vscode/settings.example.json` menjadi `.vscode/settings.json`, lalu isi kredensial lokalmu. File konfigurasi lokal tersebut sudah diabaikan oleh Git.
