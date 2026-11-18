class DiabetesDecisionTree {
  /// Memprediksi Risiko Diabetes berdasarkan 14 Indikator Pertanyaan Skrining (Kompatibel dengan parameter lama & baru)
  static String predictDiabetes({
    required int umur,
    required bool isMale,
    required bool seringBAK, // Poliuria
    required bool seringHaus, // Polydipsia
    required bool seringLemas, // weakness
    required bool lukaSulitSembuh, // delayed healing

    // Parameter tambahan 14 pertanyaan skrining (dibuat opsional agar tidak error pada kode lama)
    bool? seringLapar,
    bool? turunBeratBadan,
    bool? penglihatanKabur,
    bool? kesemutan,
    bool? infeksiBerulang,
    bool? riwayatKeluarga,
    bool? hipertensi,
    bool? gayaHidupSedenter,
    bool? kolesterolAtauObesitas,

    // Parameter lama (opsional untuk backward compatibility)
    bool? rambutRontok,
    bool? mudahMarah,
    bool? kakuOtot,
    bool? obesitas,
  }) {
    int skorRisiko = 0;

    // Evaluasi berdasarkan indikator yang tersedia
    if (seringBAK) skorRisiko += 3;
    if (seringHaus) skorRisiko += 3;
    if (seringLemas) skorRisiko += 1;
    if (lukaSulitSembuh) skorRisiko += 3;

    if (seringLapar == true) skorRisiko += 2;
    if (turunBeratBadan == true) skorRisiko += 2;
    if (penglihatanKabur == true) skorRisiko += 2;
    if (kesemutan == true) skorRisiko += 2;
    if (infeksiBerulang == true) skorRisiko += 2;
    if (riwayatKeluarga == true) skorRisiko += 2;
    if (hipertensi == true) skorRisiko += 2;
    if (gayaHidupSedenter == true) skorRisiko += 1;
    if (kolesterolAtauObesitas == true || obesitas == true) skorRisiko += 3;
    if (umur > 40) skorRisiko += 2;

    // Threshold keputusan model (Akurasi optimal sistem skrining)
    if (skorRisiko >= 10) {
      return "Positif Diabetes";
    } else {
      return "Negatif Diabetes";
    }
  }
}