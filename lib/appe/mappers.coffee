toDate = (value) ->
  if value instanceof Date
    value
  else
    new Date(value)

mappers =
  date:
    year: (value)    -> toDate(value).getFullYear()
    month: (value)   -> toDate(value).getMonth() + 1
    day: (value)     -> toDate(value).getDate()

    weekday: (value) ->
      wday = toDate(value).getDay()
      if wday == 0
        7
      else
        wday

module.exports = mappers
