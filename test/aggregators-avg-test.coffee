aggregators = require '../lib/appe/aggregators'
mocha       = require 'mocha'
assert      = require 'assert'

describe("avg aggregator", ->
  it("gets average of all values submitted to it", ->
    avg = aggregators.avg()
    avg.update(10)
    avg.update(20)
    avg.update(30)

    assert.equal(20.0, avg.value())
  )

  it("ignores non-numeric values", ->
    avg = aggregators.avg()
    avg.update(10)
    avg.update("10")
    avg.update([1,2])
    avg.update(20)
    avg.update(30)

    assert.equal(20.0, avg.value())
  )
)
