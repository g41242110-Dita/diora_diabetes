class DiabetesDecisionTree {
  /// Memprediksi Risiko Diabetes berdasarkan hasil Decision Tree Google Colab (Akurasi 93.65%)
  static String predictDiabetes({
    required int umur,
    required bool isMale, // true = Male (>0.50), false = Female (<=0.50)
    required bool seringBAK, // Polyuria
    required bool seringHaus, // Polydipsia
    required bool seringLemas, // weakness
    required bool rambutRontok, // Alopecia
    required bool lukaSulitSembuh, // delayed healing
    required bool mudahMarah, // Irritability
    required bool kakuOtot, // muscle stiffness
    required bool obesitas, // Obesity
  }) {
    // 1. Sering BAK <= 0.50 (TIDAK SERING BAK)
    if (!seringBAK) {
      // Jenis Kelamin <= 0.50 (PEREMPUAN)
      if (!isMale) {
        if (!rambutRontok) {
          return umur <= 34 ? "Negatif Diabetes" : "Positif Diabetes";
        } else {
          return !lukaSulitSembuh ? "Positif Diabetes" : "Negatif Diabetes";
        }
      }
      // Jenis Kelamin > 0.50 (LAKI-LAKI)
      else {
        if (!seringHaus) {
          return "Negatif Diabetes";
        } else {
          return !kakuOtot ? "Positif Diabetes" : "Negatif Diabetes";
        }
      }
    }
    // 2. Sering BAK > 0.50 (YA, SERING BAK)
    else {
      if (umur <= 69) {
        if (!seringHaus) {
          return !obesitas ? "Positif Diabetes" : "Negatif Diabetes";
        } else {
          return "Positif Diabetes";
        }
      } else {
        return seringLemas ? "Positif Diabetes" : "Negatif Diabetes";
      }
    }
  }
}