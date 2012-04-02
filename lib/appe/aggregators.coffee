_ = require 'underscore'

distinctValues = (options) ->
    options = _.extend(
        trim       : false
        ignoreCase : false
        limit      : -1
        , options
    )

    valueFrequencies  = {}

    addValue = (value) ->
        value = value.trim() if options.trim
        value = value.toLowerCase() if options.ignoreCase

        valueFrequencies[value] ||= 0
        valueFrequencies[value] += 1

    cmpMostFrequentFirst = (a, b) ->
        b.frequency - a.frequency

    methods =
        update: (value) ->
            if value instanceof Array
                addValue(x) for x in value
            else
                addValue(value)

        value: ->
            values = []

            for own value, frequency of valueFrequencies
                values.push({ value : value, frequency : frequency })

            values.sort(cmpMostFrequentFirst)

            if options.limit != -1
                values.splice(0, options.limit)
            else
                values

sum = (options) ->
    currentSum = 0.0

    methods =
        update: (value) ->
            if typeof value != 'number'
                return

            currentSum += value

        value: ->
            currentSum

avg = (options) ->
    total = 0.0
    count = 0

    methods =
        update: (value) ->
            if typeof value != 'number'
                return

            total += value
            count += 1

        value: ->
            total / count

module.exports =
    distinctValues : distinctValues
    sum            : sum
    avg            : avg
