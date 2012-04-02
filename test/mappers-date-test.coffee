mappers = require '../lib/appe/mappers'
mocha   = require 'mocha'
assert  = require 'assert'

describe("date mappers", ->
  it("can map date to it's year component", ->
    assert.equal(2012, mappers.date.year("2012-03-10"))
  )

  it("can map date to it's month component", ->
    assert.equal(3, mappers.date.month("2012-03-10"))
  )

  it("can map date to it's day component", ->
    assert.equal(10, mappers.date.day("2012-03-10"))
  )

  it("can map date to it's weekday", ->
    assert.equal(6, mappers.date.weekday("2012-03-10"))
  )
)
