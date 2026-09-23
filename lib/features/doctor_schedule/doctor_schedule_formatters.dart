String doctorMonthName(int month) => const [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
][month - 1];

String doctorMonthGenitive(int month) => const [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
][month - 1];

String doctorWeekdayShort(int weekday) =>
    const ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'][weekday - 1];

String doctorDateLabel(DateTime date) =>
    '${date.day} ${doctorMonthGenitive(date.month)}, '
    '${doctorWeekdayShort(date.weekday)}';

String doctorTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

String doctorTimeRange(DateTime start, DateTime end) =>
    '${doctorTime(start)}–${doctorTime(end)}';
