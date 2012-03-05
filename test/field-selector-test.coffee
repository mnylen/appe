{Event}         = require '../lib/appe/model'
{FieldSelector} = require '../lib/appe/model'
mocha           = require 'mocha'
assert			= require 'assert'

describe("FieldSelector", ->
	describe("selectFields", ->
		beforeEach(->
			this.event = new Event('order',
				id          : 10
				name        : "Appe"
				price       : 0.00
				quantity    : 10
				total_price : 0

				delivery_address:
					street_address : "Appe Avenue"
					zip_code       : "00510"
					country        : "Finland"

				states: {}
			)
		)

		it("selects field and it's value", ->
			fields = new FieldSelector("name").selectFields(this.event)
			assert.deepEqual(fields,
				name : "Appe"
			)
		)

		it("selects field and it's value from object-valued field using dot syntax", ->
			fields = new FieldSelector("delivery_address.country").selectFields(this.event)
			assert.deepEqual(fields,
				"delivery_address.country" : "Finland"
			)
		)

		it("selects multiple fields using array of selectors", ->
			fields = new FieldSelector(["id", "name", "delivery_address.zip_code"]).selectFields(this.event)
			assert.deepEqual(fields,
				id       					: 10
				name     					: "Appe"
				"delivery_address.zip_code" : "00510"
			)
		)

		it("selects multiple fields using asterisk syntax", ->
			fields = new FieldSelector("*").selectFields(this.event)
			assert.deepEqual(fields,
				id          : 10
				name        : "Appe"
				price       : 0.00
				quantity    : 10
				total_price : 0
			)
		)

		it("selects multiple fields using dot syntax and asterisk syntax", ->
			fields = new FieldSelector("delivery_address.*").selectFields(this.event)
			assert.deepEqual(fields,
				"delivery_address.street_address" : "Appe Avenue"
				"delivery_address.zip_code"       : "00510"
				"delivery_address.country"        : "Finland"
			)
		)

		it("selects field with null value if the selector does not match", ->
			fields = new FieldSelector("qaantity").selectFields(this.event)
			assert.deepEqual(fields,
				qaantity: null
			)

			fields = new FieldSelector("delivery_address.po_box").selectFields(this.event)
			assert.deepEqual(fields,
				"delivery_address.po_box" : null
			)
		)

		it("selects zero fields using asterisk if using .* syntax on non-object-valued field", ->
			fields = new FieldSelector("id.*").selectFields(this.event)
			assert.deepEqual(fields, {})
		)

		it("selects zero fields using asterisk if using .* syntax on empty object-valued field", ->
			fields = new FieldSelector("states.*").selectFields(this.event)
			assert.deepEqual(fields, {})
		)
	)
)