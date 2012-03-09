{Event}         = require '../lib/appe/model'
{FieldSelector} = require '../lib/appe/model'
aggregators = require '../lib/appe/aggregators'
mocha       = require 'mocha'
assert      = require 'assert'

describe("aggregators", ->
    describe("distinctValues", ->
        it("collects all distinct values and returns them in order of frequency", ->
            distinct = aggregators.distinctValues()
            distinct.update("hello")
            distinct.update("world")
            distinct.update("world")
            distinct.update("world")
            distinct.update("hello")
            distinct.update("lorem")

            assert.deepEqual(distinct.value(), [
                { value : "world", frequency : 3 }
                { value : "hello", frequency : 2 }
                { value : "lorem", frequency : 1 }
            ])
        )

        it("collects distinct values from array", ->
            distinct = aggregators.distinctValues()
            distinct.update(["hello", "world", "hello", "hello", "world"])

            assert.deepEqual(distinct.value(), [
                { value : "hello", frequency : 3 }
                { value : "world", frequency : 2 }
            ])
        )

        it("collects distinct values and returns only n most frequent values", ->
            distinct = aggregators.distinctValues(limit : 2)

            distinct.update([
                "hello"
                "hello"
                "hello"
                "hello"
                "world"
                "world"
                "world"
                "ipsum"
                "ipsum"
                "dolor"
            ])

            assert.deepEqual(distinct.value(), [
                { value : "hello", frequency : 4 }
                { value : "world", frequency : 3 }
            ])
        )

        it("doesn't ignore case by default", ->
            distinct = aggregators.distinctValues()
            distinct.update(["HELLO", "hello", "hello"])

            assert.deepEqual(distinct.value(), [
                { value : "hello", frequency : 2}
                { value : "HELLO", frequency : 1}
            ])
        )

        it("ignores case with ignoreCase : true", ->
            distinct = aggregators.distinctValues(ignoreCase : true)
            distinct.update(["HELLO", "hello", "hello"])

            assert.deepEqual(distinct.value(), [
                { value : "hello", frequency : 3 }
            ])
        )

        it("doesn't ignore leading and trailing whitespace by default", ->
            distinct = aggregators.distinctValues()
            distinct.update(["hello  ", "  hello", "hello"])

            assert.deepEqual(distinct.value(), [
                { value : "hello  ", frequency : 1 },
                { value : "  hello", frequency : 1 },
                { value : "hello",   frequency : 1 }
            ])
        )

        it("ignores leading and trailing whitespace with trim : true", ->
            distinct = aggregators.distinctValues(trim : true)
            distinct.update(["hello  ", "  hello", "hello"])

            assert.deepEqual(distinct.value(), [
                { value : "hello", frequency : 3 }
            ])
        )
    )
)