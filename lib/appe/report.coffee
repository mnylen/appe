_               = require 'underscore'
{FieldSelector} = require './model'

normalizeOptions = (options) ->
    # groupBy can contain string entries, GroupBy entries
    # and FieldSelector entries. These need to be normalized
    # as GroupBy entries for easier processing.
    groupBy = []

    options.groupBy ||= []
    if options.groupBy and not (options.groupBy instanceof Array)
        options.groupBy = [options.groupBy]

    for group in options.groupBy
        if typeof group == 'string'
            groupBy.push(new GroupBy(new FieldSelector(group), {}))
        else if group instanceof GroupBy
            groupBy.push(group)
        else if group instanceof FieldSelector
            groupBy.push(new GroupBy(group, {}))

    options.groupBy = groupBy

    # aggregators.*.valueSelector can be either string or FieldSelector.
    # Normalize all these as FieldSelectors
    options.aggregators ||= {}
    for own aggregatorName, aggregatorOptions of options.aggregators
        if typeof aggregatorOptions.valueSelector == 'string'
            aggregatorOptions.valueSelector = new FieldSelector(aggregatorOptions.valueSelector)

    options


report = (events, options, cb) ->
    options = normalizeOptions(options)

    if events.length == 0
        cb(count : 0)
    else
        new Report(events, options, cb).compute()


class Report
    constructor: (@events, @options, @cb) ->
        @index = 0
        @root  = new Group(null, 'ROOT')

    compute: ->
        toIndex = @index + 100000
        if toIndex >= @events.length
            toIndex = @events.length - 1 

        for i in [@index..toIndex]
            @.addEvent(@events[i])

        @index = toIndex + 1
        if @index < @events.length
            self = this
            process.nextTick -> (self.compute()) 
        else
            @cb(@root.toObject())

    addEvent: (event) ->
        @root.incrCount()
        @.updateAggregators(event, null, @root)

        parents = [@root]

        for group in @options.groupBy
            fields = group.selector.selectFields(event)
            newParents = []

            for own fieldName, value of fields
                groupName = if group.options.fieldName then fieldName else value

                for parent in parents
                    child = parent.child(groupName)
                    child.incrCount()
                    @.updateAggregators(event, value, child)
                    newParents.push(child)

            parents = newParents

    updateAggregators: (event, groupValue, group) ->
        for own aggregatorName, aggregatorOptions of @options.aggregators
            aggregator = group.aggregator(aggregatorName, aggregatorOptions)

            if aggregatorOptions.valueSelector
                aggregatorFields = aggregatorOptions.valueSelector.selectFields(event)

                for own aggregatedFieldName, aggregatedValue of aggregatorFields
                    aggregator.update(aggregatedValue)
            else
                aggregator.update(groupValue)


class Group
    constructor: (@parent, @name) ->
        @count       = 0
        @children    = {}
        @aggregators = {}

    incrCount: ->
        @count += 1

    child: (name) ->
        @children[name] ||= new Group(@, name)

    aggregator: (name, options) ->
        if @aggregators[name] == undefined
            @aggregators[name] = options.aggregator(options.options)
        
        @aggregators[name]

    toObject: ->
        obj = { count : @count }

        for own aggregatorName, aggregator of @aggregators
            obj[aggregatorName] = aggregator.value()

        for own childGroupName, child of @children
            obj.groups ||= {}
            obj.groups[childGroupName] = child.toObject()

        obj


class GroupBy
    constructor: (@selector, options) ->
        if typeof @selector == 'string'
            @selector = new FieldSelector(@selector)

        @options = _.extend(
            fieldName : false
            , options
        )


module.exports =
    GroupBy : GroupBy
    report  : report
