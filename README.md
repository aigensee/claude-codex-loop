# claude-codex-loop

Template kerja **Claude → Codex → Claude**: Claude merencanakan dan
me-review, Codex menulis kode, manusia menyetujui deploy. Pasang ke project
mana pun dengan satu perintah.

## Pembagian peran

| Peran | Mengerjakan | Tidak boleh |
|---|---|---|
| **Manusia (maintainer)** | Memberi tugas, memutuskan scope, **menyetujui setiap deploy** | — |
| **Claude** | Analisis, arsitektur, menulis `PLAN.md`, menjalankan Codex, review diff, menjalankan ulang semua check, deploy setelah disetujui | Mengedit kode sendiri (varian ketat) |
| **Codex** | Implementasi, bug fix, test terarah, sesuai plan | Deploy, menyentuh server/data production, push ke `main`, mengubah scope tanpa bertanya |

Prinsipnya: **yang menulis kode bukan yang menilai kode.** Claude tidak
percaya laporan Codex begitu saja; semua check dijalankan ulang.

## Alur satu tugas

```
TASK.md ──► PLAN.md ──► (codex exec) ──► RESULT.md ──► REVIEW.md
 manusia     Claude        Codex           Codex         Claude
                                                           │
                    ┌── perbaikan bernomor ◄───────────────┤ belum OK
                    ▼                                       │
                 Codex lagi ──► RESULT.md ──► REVIEW.md     │ OK
                                                            ▼
                                     merge lokal → minta izin deploy → push
```

1. **TASK**: permintaan manusia (atau Claude menyalinnya dari chat).
2. **PLAN**: Claude menganalisis kode lalu menulis plan yang cukup konkret
   sehingga Codex tidak perlu menganalisis ulang: branch, file/simbol,
   pendekatan, docs yang wajib diupdate, check yang dijalankan, di luar scope.
3. **Codex**: dijalankan non-interaktif oleh Claude, bekerja di branch dari
   plan, commit tapi tidak push.
4. **RESULT**: Codex melaporkan perubahan, commit, dan **output asli** setiap
   check.
5. **REVIEW**: Claude membaca diff terhadap plan, menjalankan ulang check,
   cek dampak dan aturan docs. Hasilnya `APPROVED` atau perbaikan bernomor.
6. **Deploy**: hanya setelah manusia menyetujui deploy *itu*.

Tugas yang selesai dipindah ke `.agent/<nama-tugas>/` sebagai arsip.

---

## Cara pakai

### 1. Persiapan (sekali saja)

- Install [Claude Code](https://claude.com/claude-code) dan
  [Codex CLI](https://github.com/openai/codex), login ke keduanya.
- Clone repo ini:
  ```bash
  git clone https://github.com/aigensee/claude-codex-loop.git ~/Code/claude-codex-loop
  ```

### 2. Pasang ke project

```bash
~/Code/claude-codex-loop/install.sh /path/ke/project
```

Script menyalin:

```
project/
├── AGENTS.md            aturan bersama (dibaca Claude dan Codex)
├── .claude/CLAUDE.md    aturan khusus Claude, meng-import AGENTS.md
└── .agent/              file handoff: TASK, PLAN, RESULT, REVIEW
```

File yang sudah ada **tidak ditimpa** (tambahkan `--force` untuk menimpa).
Kalau project-nya repo git, `.agent/` otomatis masuk `.gitignore`.

### 3. Isi `AGENTS.md`

Ganti semua `<...>`:
- **Repo map**: folder-folder utama dan dokumen yang harus dibaca dulu.
- **Testing**: perintah check per bagian, misalnya
  `npm run lint && npx tsc --noEmit` atau `go test ./...`.
- **Production restrictions**: apa yang memicu deploy (misal push ke
  `main`), file `.env` mana yang mengarah ke production, link prosedur deploy.

Di `.claude/CLAUDE.md`, isi cara akses server (tanpa menulis password/key).

Tips: cukup minta Claude *"isi AGENTS.md sesuai project ini"*. Claude akan
membaca project lalu mengisinya.

### 4. Kerja sehari-hari

Buka Claude Code di root project, lalu ngobrol biasa:

> Tambahkan filter tanggal di halaman Transaksi.

Claude akan:
1. Menganalisis kode dan menulis `.agent/PLAN.md`.
2. Menjalankan Codex di background:
   ```bash
   codex exec --skip-git-repo-check -s workspace-write -C <root> \
     "Read AGENTS.md and .agent/PLAN.md. Implement the plan exactly, run the checks, write .agent/RESULT.md." \
     < /dev/null > <log> 2>&1
   ```
3. Membaca `RESULT.md`, me-review, menulis `REVIEW.md`, dan mengulang ke
   Codex sampai `APPROVED`.
4. Melapor ke kamu dan **bertanya dulu sebelum deploy/push**.

Mau menyetujui rencana dulu sebelum Codex jalan? Bilang *"tunjukkan plan
dulu sebelum jalankan Codex"*.

### 5. Kalau Codex macet

| Gejala | Penyebab | Solusi |
|---|---|---|
| Codex diam, log berisi "Reading additional input from stdin..." | stdin tidak ditutup | Tambahkan `< /dev/null` |
| "Not inside a trusted directory" | root bukan repo git | Tambahkan `--skip-git-repo-check` |
| `--full-auto` ditolak | versi Codex baru | Pakai `-s workspace-write` |
| Test yang butuh port localhost/Docker gagal di Codex | batasan sandbox | Normal; Claude menjalankan ulang test itu di luar sandbox |

---

## Varian ketat vs longgar

Default template ini **ketat**: Claude tidak mengedit kode sama sekali,
perbaikan satu baris pun lewat `REVIEW.md` ke Codex. Claude tetap boleh git
branch/merge, migrasi lokal, restart server, dan mengurus `.agent/`.

Untuk varian **longgar** (Claude boleh memperbaiki hal kecil sendiri), ganti
poin "Claude never edits code" di `.claude/CLAUDE.md` dengan:

```
- Small or urgent fixes you may implement yourself; say so in `RESULT.md`.
```

## Isi repo

| File | Gunanya |
|---|---|
| `install.sh` | Menyalin template ke project |
| `template/AGENTS.md` | Aturan bersama: peran, eksplorasi kode, testing, production |
| `template/.claude/CLAUDE.md` | Tambahan khusus Claude: plan, review, deploy |
| `template/.agent/TASK.md` | Format permintaan |
| `template/.agent/PLAN.md` | Format plan dari Claude |
| `template/.agent/RESULT.md` | Format laporan Codex |
| `template/.agent/REVIEW.md` | Format review Claude |
