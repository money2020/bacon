

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
        data:
            name: chance.name()
        $timeout addGood, Math.random() * 1000

    addFraud = -> State.add
        id: 'fraud' + Math.random()
        score: 0.5
        state:
            id:    'fraud'
            label: 'Fraud'
            icon:  'close'
        data:
            name: chance.name()
        $timeout addFraud, Math.random() * 5000

    $timeout addGood, 0
    $timeout addFraud, 0

    updateState = ->
        console.log 'getting sketchy transactions'
        TransactionAPI.getSketchyTransactions().then (transactions) ->
            console.log "IN LOOP:", JSON.stringify(transactions, null, 2)
            State.updateSketchy(transactions)
            $timeout updateState, 1000

    updateState()




.constant('TransactionStates', {'ok', 'fraud'})



# .factory 'transactionSocket', (socketFactory) ->
    # return socketFactory()



# {
#   "data": [
#     {
#       "created_at": 1414937631,
#       "data": {
#         "amount": 4300,
#         "id": 1414937631,
#         "ip": "212.10.114.18",
#         "user_email": "howey.1975@gmail.com",
#         "user_id": "1234s56"
#       },
#       "id": "1414937631",
#       "score": 0.677,
#       "state": {
#         "id": "sketchy",
#         "label": "sketchy"
#       },
#       "status": "unverified",
#       "updated_at": 1414937631,
#       "verification": "sms"
#     },
#     {
#       "created_at": 1414937660,
#       "data": {
#         "amount": 7200,
#         "id": 1414937660,
#         "ip": "212.10.114.18",
#         "user_email": "howey.1975@gmail.com",
#         "user_id": "1234s56"
#       },
#       "id": "1414937660",
#       "score": 0.679,
#       "state": {
#         "id": "sketchy",
#         "label": "sketchy"
#       },
#       "status": "ok",
#       "updated_at": 1414937660,
#       "verification": "sms"
#     },
#     {
#       "created_at": 1414937691,
#       "data": {
#         "amount": 9300,
#         "id": 1414937691,
#         "ip": "212.10.114.18",
#         "user_email": "howey.1975@gmail.com",
#         "user_id": "1234s56"
#       },
#       "id": "1414937691",
#       "score": 0.679,
#       "state": {
#         "id": "sketchy",
#         "label": "sketchy"
#       },
#       "status": "fraud",
#       "updated_at": 1414937691,
#       "verification": "sms"
#     }
#   ]
# }


.service 'TransactionAPI', ($q, $http) ->

    getRaw = -> $http.get('http://crispybacon.ngrok.com/auth/SMSAuth/status2').then (response) ->
        return [] if not response.data or not response.data.data
        data = response.data.data
        data = data.filter (x) -> not (x.status in ["fraud", "ok"])
        console.log JSON.stringify(data, null, 2)
        return data

    # getRaw = -> $q (resolve, reject) -> resolve([])

    # getRaw = -> new $q (resolve, reject) ->
    #     return resolve data: [
    #         {
    #               "created_at": 1414937631,
    #               "data": {
    #                 "amount": 4300,
    #                 "id": 1414937631,
    #                 "ip": "212.10.114.18",
    #                 "user_email": "howey.1975@gmail.com",
    #                 "user_id": "1234s56"
    #               },
    #               "id": "1414937631",
    #               "score": 0.677,
    #               "state": {
    #                 "id": "sketchy",
    #                 "label": "sketchy"
    #               },
    #               "status": "unverified",
    #               "updated_at": 1414937631,
    #               "verification": "sms"
    #         }
    #     ]

    getSketchyTransactions: ->
        getRaw().then (data) ->
            return {stats:{}, label:'Sketchy Transactions', transactions:(_.indexBy data, 'id')}


.factory 'AppState', ($timeout, TransactionStates) ->
    return (state) ->

        initState = ->
            result         = {}
            result.sketchy = {}
            result.ok      = {label:'ok',    icon:'check', stats:{}, transactions:{}}
            result.fraud   = {label:'fraud', icon:'cross', stats:{}, transactions:{}}
            return result

        update = (newState) ->
            newState = JSON.parse JSON.stringify(newState)
            state ?= {}
            console.log "NEW STATE:", JSON.stringify(newState, null, 2)
            state.sketchy  = {stats:{}, label:'Sketchy Transactions', transactions:newState.sketchy.transactions}
            state.ok       = {label:'ok',    icon:'check', stats:state.ok.stats, transactions:{}}
            state.fraud    = {label:'fraud', icon:'cross', stats:state.ok.stats, transactions:{}}

        update initState() if not state

        getState: ->
            return state

        updateSketchy: (sketchy) ->
            $timeout (-> console.log state), 0
            return update({sketchy})

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
                state.sketchy ?= {label, stats:{}, transactions:{}}
                state.sketchy.stats ?= {}
                state.sketchy.stats.count ?= 0
                state.sketchy.stats.count++
                state.sketchy.transactions ?= {}
                state.sketchy.transactions[transaction.id] = transaction

        del: (transaction) ->
            isTransient = transaction.state.id in [TransactionStates.ok, TransactionStates.fraud]
            collection = do ->
                return state[transaction.state.id] if isTransient
                return state.sketchy
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


.directive 'transactionListSketchy', ->
    restrict: 'E'
    replace: true
    templateUrl: '/widgets/widget-transaction-list-sketchy.html'
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
        ), 100
