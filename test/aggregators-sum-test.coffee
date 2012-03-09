{Event}         = require '../lib/appe/model'
{FieldSelector} = require '../lib/appe/model'
aggregators = require '../lib/appe/aggregators'
mocha       = require 'mocha'
assert      = require 'assert'

describe("sum aggregator", ->
	it("sums values given to it", ->
		sum = aggregators.sum()
		sum.update(1)
		sum.update(2)
		sum.update(3)

		assert.equal(6, sum.value())
	)

	it("ignores non-numeric values", ->
		sum = aggregators.sum()
		sum.update("hello")
		sum.update(1)
		sum.update({ "hello" : "world"})
		sum.update([1,2,3])

		assert.equal(1, sum.value())
	)
)