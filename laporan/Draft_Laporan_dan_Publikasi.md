# Draft Laporan UTS & Rancangan Sistem
## Judul: Palm Oil Ripeness Classification Using CNN INT8 on SoC FPGA Cyclone V

### 1. Ringkasan Eksekutif
Proyek ini mengembangkan sistem klasifikasi tingkat kematangan Tandan Buah Segar (TBS) kelapa sawit secara *real-time* menggunakan arsitektur *Convolutional Neural Network* (CNN) terkuantisasi **INT8** yang diakselerasi pada perangkat keras **Intel SoC FPGA Cyclone V**.

### 2. Kebaruan & Kelayakan Teknis
- Pemanfaatan fitur warna **RGB (3-kanal)** pada resolusi **32×32 piksel** untuk menangkap transisi pigmen antosianin (ungu kehitaman pada buah mentah) menuju karotenoid (jingga kemerahan pada buah matang).
- Reduksi kebutuhan memori parameter hingga 75% melalui kuantisasi bobot **8-bit signed integer (INT8)** sehingga seluruh bobot (~2,9 KB) muat pada memori internal **M10K BRAM** Cyclone V.
- Kolaborasi *Hard Processor System* (HPS ARM Cortex-A9) untuk pra-pemrosesan citra dan *FPGA Fabric* (Verilog RTL) untuk komputasi konvolusi paralel berlatensi rendah.
