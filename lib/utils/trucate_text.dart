String truncateText(String text, int limit) {
  if (text.length <= limit + 10) return text;
  return '${text.substring(0, limit)}...${text.substring(text.length - 10, text.length)}';
}