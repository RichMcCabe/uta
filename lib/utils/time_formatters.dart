String signedMinutes(int minutes) {
  if (minutes == 0) return 'On plan';
  if (minutes > 0) return '+$minutes min behind';
  return '${minutes.abs()} min ahead';
}
