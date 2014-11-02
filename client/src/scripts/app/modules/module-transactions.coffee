

angular.module('money2020.bacon.transactions', [
    # 'btford.socket-io'
])


.controller 'TransactionsController', ($scope, $timeout, TransactionAPI, State) ->
    console.log "Transaction Controller Initialized"

    $scope.State = State

    State.add
        id: 'sketchysms01'
        score: 0.5
        state:
            id:    'sms'
            label: 'Sketchy SMS'

    addGood = -> State.add
        id: 'good' + Math.random()
        score: 0.5
        state:
            id:    'ok'
            label: 'Good'
        $timeout addGood, Math.random() * 1000

    addFraud = -> State.add
        id: 'fraud' + Math.random()
        score: 0.5
        state:
            id:    'fraud'
            label: 'Fraud'
        $timeout addFraud, Math.random() * 5000

    $timeout addGood, 0
    $timeout addFraud, 0

    # updateState()


.constant('TransactionStates', {'ok', 'fraud'})



# .factory 'transactionSocket', (socketFactory) ->
    # return socketFactory()



.service 'TransactionAPI', ($q, $http) ->

    getState: -> new $q (resolve, reject) -> resolve(null)

    getSketchyTransactions: ->



.factory 'AppState', ($timeout, TransactionStates) ->
    return (state) ->

        initState = ->
            result         = {}
            result.sketchy = {}
            result.ok      = {label:'ok', stats:{}, transactions:{}}
            result.fraud   = {label:'fraud', stats:{}, transactions:{}}
            return result

        update = (newState) ->
            newState = JSON.parse JSON.stringify(newState)
            state ?= {}
            state.sketchy  = newState.sketchy
            state.ok       = {label:'ok', stats:{}, transactions:{}}
            state.fraud    = {label:'fraud', stats:{}, transactions:{}}

        update initState() if not state

        getState: ->
            return state

        updateSketchy: (sketchy) ->
            return update(newState)

        add: (transaction) ->
            isTransient = transaction.state.id in [TransactionStates.ok, TransactionStates.fraud]
            if isTransient
                state[transaction.state.id] ?= {stats:{}, transactions:{}}
                state[transaction.state.id].stats.count ?= 0
                state[transaction.state.id].stats.count++
                state[transaction.state.id].transactions[transaction.id] = transaction
                ($timeout (=> @del(transaction)), 1800)
            else
                label = transaction.state.label
                state.sketchy[transaction.state.id] ?= {label, stats:{}, transactions:{}}
                state.sketchy[transaction.state.id].stats.count ?= 0
                state.sketchy[transaction.state.id].stats.count++
                state.sketchy[transaction.state.id].transactions[transaction.id] = transaction

        del: (transaction) ->
            isTransient = transaction.state.id in [TransactionStates.ok, TransactionStates.fraud]
            collection = do ->
                return state[transaction.state.id] if isTransient
                return state.sketchy[transaction.state.id]
            delete collection.transactions[transaction.id]


# # Unique identifier for the transaction
# id: ''
# # The score from 0.0 to 1.0
# score: 0.0
# # The transaction state
# state:
#   id:    '' # GOOD, BAD or SKETCHY
#   label: '' # The text associated to the id
# created_at: '' # unix timestamp
# updated_at: '' # unix timestamp
# data: {} # arbitrary data


# .service 'State', ($timeout, TransactionStates) ->
#     state = {}

#     getState: ->
#         return state

#     add: (transaction) ->
#         isTransient = transaction.state.id in [TransactionStates.GOOD, TransactionStates.BAD]
#         if isTransient
#             state.transient[transaction.state.id] ?= {}
#             state.transient[transaction.state.id][transaction.id] = transaction
#             ($timeout (=> @del(transaction)), Math.random() * 500)
#         else
#             state.sketchy[transaction.substate.id] ?= {}
#             state.sketchy[transaction.substate.id][transaction.id] = transaction

#     del: (transaction) ->
#         isTransient = transaction.state.id in [TransactionStates.GOOD, TransactionStates.BAD]
#         collection = do ->
#             return state.transient[transaction.state.id] if isTransient
#             return state.sketchy[transaction.substate.id]
#         delete collection[transaction.id]


.directive 'transactions', ->
    restrict: 'E'
    replace: true
    templateUrl: '/widgets/widget-transactions.html'
    link: (scope) ->
        scope.state = scope.State.getState()


.directive 'transactionList', ->
    restrict: 'E'
    replace: true
    templateUrl: '/widgets/widget-transaction-list.html'
    scope:
        state:   '='
        animate: '='


.directive 'transactionListItem', ($timeout) ->
    restrict: 'C'
    link: (scope, element) ->
        console.log 'sup'
        $el = $(element)
        $timeout (->
            return if not $el.hasClass('fallanimation')
            velocity = Math.random() * (10 - 6) + 6
            $timeout (-> $el.box2d({'y-velocity':velocity})), 0
        ), 0
