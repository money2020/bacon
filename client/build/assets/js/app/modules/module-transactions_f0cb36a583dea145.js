(function(){angular.module("money2020.bacon.transactions",[]).controller("TransactionsController",function($scope,$timeout,TransactionAPI,State){var addFraud,addGood,updateState;return console.log("Transaction Controller Initialized"),$scope.State=State,State.add({id:"sketchysms01",score:.5,state:{id:"sms",label:"Sketchy SMS"}}),addGood=function(){return State.add({id:"good"+Math.random(),score:.5,state:{id:"ok",label:"Good"},data:{name:chance.name()}},$timeout(addGood,1e3*Math.random()))},addFraud=function(){return State.add({id:"fraud"+Math.random(),score:.5,state:{id:"fraud",label:"Fraud",icon:"close"},data:{name:chance.name()}},$timeout(addFraud,5e3*Math.random()))},$timeout(addGood,0),$timeout(addFraud,0),(updateState=function(){return TransactionAPI.getSketchyTransactions().then(function(transactions){return State.updateSketchy(transactions)})})()}).constant("TransactionStates",{ok:"ok",fraud:"fraud"}).service("TransactionAPI",function($q,$http){var getRaw;return getRaw=function(){return $http.get("/auth/SMSAuth/status2").then(function(data){return data=data.data,data=data.filter(function(x){var _ref;return!("fraud"===(_ref=x.status)||"ok"===_ref)})})},{getSketchyTransactions:function(){return getRaw().then(function(data){return{stats:{},label:"Sketchy Transactions",transactions:_.indexBy(data.data,"id")}})}}}).factory("AppState",function($timeout,TransactionStates){return function(state){var initState,update;return initState=function(){var result;return result={},result.sketchy={},result.ok={label:"ok",icon:"check",stats:{},transactions:{}},result.fraud={label:"fraud",icon:"cross",stats:{},transactions:{}},result},update=function(newState){return newState=JSON.parse(JSON.stringify(newState)),null==state&&(state={}),state.sketchy=newState.sketchy,state.ok={label:"ok",icon:"check",stats:{},transactions:{}},state.fraud={label:"fraud",icon:"cross",stats:{},transactions:{}}},state||update(initState()),{getState:function(){return state},updateSketchy:function(sketchy){return $timeout(function(){return console.log(state)},0),update({sketchy:sketchy})},add:function(transaction){var isTransient,label,_base,_base1,_base2,_base3,_name,_ref,_this=this;return isTransient=(_ref=transaction.state.id)===TransactionStates.ok||_ref===TransactionStates.fraud,isTransient?(null==state[_name=transaction.state.id]&&(state[_name]={stats:{},transactions:{}}),null==(_base=state[transaction.state.id].stats).count&&(_base.count=0),state[transaction.state.id].stats.count++,state[transaction.state.id].transactions[transaction.id]=transaction,$timeout(function(){return _this.del(transaction)},1800)):(label=transaction.state.label,null==state.sketchy&&(state.sketchy={label:label,stats:{},transactions:{}}),null==(_base1=state.sketchy).stats&&(_base1.stats={}),null==(_base2=state.sketchy.stats).count&&(_base2.count=0),state.sketchy.stats.count++,null==(_base3=state.sketchy).transactions&&(_base3.transactions={}),state.sketchy.transactions[transaction.id]=transaction)},del:function(transaction){var collection,isTransient,_ref;return isTransient=(_ref=transaction.state.id)===TransactionStates.ok||_ref===TransactionStates.fraud,collection=function(){return isTransient?state[transaction.state.id]:state.sketchy}(),delete collection.transactions[transaction.id]}}}}).directive("transactions",function(){return{restrict:"E",replace:!0,templateUrl:"/widgets/widget-transactions.html",link:function(scope){return scope.state=scope.State.getState()}}}).directive("transactionList",function(){return{restrict:"E",replace:!0,templateUrl:"/widgets/widget-transaction-list.html",scope:{state:"=",animate:"="}}}).directive("transactionListSketchy",function(){return{restrict:"E",replace:!0,templateUrl:"/widgets/widget-transaction-list-sketchy.html",scope:{state:"=",animate:"="}}}).directive("transactionListItem",function($timeout){return{restrict:"C",link:function(scope,element){var $el;return console.log("sup"),$el=$(element),$timeout(function(){var velocity;if($el.hasClass("fallanimation"))return velocity=4*Math.random()+6,$timeout(function(){return $el.box2d({"y-velocity":velocity})},0)},0)}}})}).call(this);