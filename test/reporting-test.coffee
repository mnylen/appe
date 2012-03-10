{FieldSelector} = require '../lib/appe/model'
{Event}         = require '../lib/appe/model'
report          = require '../lib/appe/report'
mocha           = require 'mocha'
assert          = require 'assert'
aggregators     = require '../lib/appe/aggregators'

orderFixture = (dateShipped, productName, quantity, aprice, region) ->
    new Event('order',
        date_shipped     : dateShipped
        product_name     : productName
        quantity         : quantity
        total_price      : quantity * aprice
        delivery_address :
            region: region
    )

describe("report.report()", ->
    describe("counting", ->
        beforeEach(->
            this.events = []
            this.events.push(orderFixture('2012-03-03', 'T-shirt', 6, 10.0, 'West'))
            this.events.push(orderFixture('2012-03-03', 'T-shirt', 1, 10.0, 'East'))
            this.events.push(orderFixture('2012-03-04', 'T-shirt', 3, 10.0, 'West'))
            this.events.push(orderFixture('2012-03-04', 'T-shirt', 2, 10.0, 'West'))
        )

        it("reports count of all events in root group", (done) ->
            report.report(this.events, {}, (report) ->
                assert.deepEqual(report,
                    count : 4
                )

                done()
            )
        )

        it("reports counts inside subgroups", (done) ->
            options =
                groupBy : new FieldSelector("date_shipped")

            report.report(this.events, options, (report) ->
                assert.deepEqual(report,
                    count  : 4
                    groups :
                        "2012-03-03" :
                            count : 2

                        "2012-03-04" :
                            count : 2
                )

                done()
            )
        )

        it("reports counts inside subsubgroups", (done) ->
            options =
                groupBy : [new FieldSelector('date_shipped'), new FieldSelector('delivery_address.region')]

            report.report(this.events, options, (report) ->
                assert.deepEqual(report,
                    count  : 4
                    groups :
                        "2012-03-03" :
                            count  : 2
                            groups :
                                "East" :
                                    count : 1

                                "West":
                                    count : 1

                        "2012-03-04" :
                            count  : 2
                            groups :
                                "West":
                                    count : 2
                )

                done()
            )
        )

        it("can group by multiple fields in same subgroup", (done) ->
            options =
                groupBy : new FieldSelector(['delivery_address.region', 'date_shipped'])

            report.report(this.events, options, (report) ->
                assert.deepEqual(report,
                    count  : 4
                    groups :
                        "East" :
                            count : 1

                        "West" :
                            count : 3

                        "2012-03-03" :
                            count : 2

                        "2012-03-04" :
                            count : 2
                )

                done()
            )
        )

        it("can group by multiple fields in same subgroup having further subgroups", (done) ->
            options =
                groupBy : [
                    new FieldSelector(['delivery_address.region', 'date_shipped'])
                    new FieldSelector(['product_name'])
                ]

            report.report(this.events, options, (report) ->
                assert.deepEqual(report,
                    count  : 4
                    groups :
                        "East" :
                            count : 1

                            groups:
                                "T-shirt":
                                    count: 1

                        "West" :
                            count : 3

                            groups:
                                "T-shirt":
                                    count:3

                        "2012-03-03" :
                            count : 2
                            groups:
                                "T-shirt":
                                    count:2

                        "2012-03-04" :
                            count : 2
                            groups:
                                "T-shirt":
                                    count: 2
                )

                done()
            )
        )
    )

    describe("counting with field names as values", ->
        beforeEach(->
            this.events = []
            this.events.push(new Event('search',
                price_range : "0 - 10 €"
                category    : "iPhone apps"
            ))

            this.events.push(new Event('search',
                category : "Web apps"
                keyword  : "Appe"
            ))

            this.events.push(new Event('search',
                price_range : "100 - 200 €",
                category    : "Devices"
            ))

            this.events.push(new Event('search',
                price_range : "10 - 20 € €",
                category    : "iPhone apps"
            ))
        )

        it("can group by multiple fields in same subgroup, using field name as group name", (done) ->
            options =
                groupBy : new report.GroupBy(new FieldSelector("*"), fieldName : true)

            report.report(this.events, options, (report) ->
                assert.deepEqual(report,
                    count : 4

                    groups:
                        price_range:
                            count: 3

                        category:
                            count : 4

                        keyword:
                            count : 1
                )

                done()
            )
        )

        it("can use both field names and field values as subgroup names", (done) ->
            options =
                groupBy : [
                    new report.GroupBy(new FieldSelector("category"), fieldName : false)
                    new report.GroupBy(new FieldSelector("*"), fieldName : true)
                ]

            report.report(this.events, options, (report) ->
                assert.deepEqual(report,
                    count : 4

                    groups:
                        "iPhone apps":
                            count  : 2

                            groups :
                                price_range:
                                    count : 2
                                category:
                                    count : 2

                        "Web apps":
                            count  : 1

                            groups :
                                keyword:
                                    count : 1

                                category:
                                    count : 1

                        "Devices":
                            count : 1

                            groups:
                                price_range:
                                    count : 1

                                category:
                                    count : 1
                )

                done()
            )
        )
    )

    describe("using aggregators", ->
        beforeEach(->
            this.events = []
            this.events.push(orderFixture('2012-03-03', 'T-shirt', 6, 10.0, 'West'))
            this.events.push(orderFixture('2012-03-03', 'Fluff toy', 1, 20.0, 'East'))
            this.events.push(orderFixture('2012-03-04', 'Fluff toy', 3, 20.0, 'West'))
            this.events.push(orderFixture('2012-03-04', 'T-shirt', 2, 10.0, 'West'))
        )

        it("includes aggregator value for every group", (done) ->
            options =
                groupBy     : ["date_shipped", "delivery_address.region"]
                aggregators :
                    total_price:
                        aggregator    : aggregators.sum
                        valueSelector : "total_price"
                    products:
                        aggregator    : aggregators.distinctValues
                        valueSelector : "product_name"

            report.report(this.events, options, (report) ->
                assert.deepEqual(report,
                    count       : 4
                    total_price : 160.0
                    products    : [
                        { value : "T-shirt",   frequency : 2 }
                        { value : "Fluff toy", frequency : 2 }
                    ]

                    groups:
                        "2012-03-03":
                            count       : 2
                            total_price : 80.0
                            products    : [
                                { value : "T-shirt",   frequency : 1 }
                                { value : "Fluff toy", frequency : 1 }
                            ]

                            groups:
                                "West":
                                    count       : 1
                                    total_price : 60.0
                                    products    : [{ value: "T-shirt", frequency : 1}]

                                "East":
                                    count       : 1
                                    total_price : 20.0
                                    products    : [{ value: "Fluff toy", frequency : 1 }]

                        "2012-03-04":
                            count : 2.0
                            total_price : 80.0
                            products    : [
                                { value : "Fluff toy",   frequency : 1 }
                                { value : "T-shirt", frequency : 1 }
                            ]

                            groups:
                                "West":
                                    count       : 2
                                    total_price : 80.0
                                    products    : [
                                        { value : "Fluff toy",   frequency : 1 }
                                        { value : "T-shirt", frequency : 1 }
                                    ]

                )

                done()
            )
        )

        it("uses current group value for aggregating if the aggregator doesn't specify valueSelector", (done) ->
            events = []
            events.push(new Event('search',
                price_range : "10 - 20 €"
                category    : "Web applications"
            ))

            events.push(new Event('search',
                price_range : "20 - 30 €"
                category    : "iPhone applications"
            ))

            events.push(new Event('search',
                category    : "iPhone applications"
                price_range : "10 - 20 €"
            ))

            options =
                groupBy     : new report.GroupBy("*", fieldName : true)
                aggregators :
                    search_terms :
                        aggregator : aggregators.distinctValues

            report.report(events, options, (report) ->
                assert.deepEqual(report,
                    count        : 3
                    groups       : 0
                    search_terms : [ { value: "null", frequency : 3 }]

                    groups:
                        price_range:
                            count : 3
                            search_terms: [
                                { value : "10 - 20 €", frequency : 2 }
                                { value : "20 - 30 €", frequency : 1 }
                            ]

                        category:
                            count: 3
                            search_terms: [
                                { value : "iPhone applications", frequency : 2 }
                                { value : "Web applications",    frequency : 1 }
                            ]
                )

                done()
            )
        )
    )
)