+"use strict";

var Elm = Elm || { Native: {} };
Elm.Native.Facebook = {};
Elm.Native.Facebook.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Facebook = localRuntime.Native.Facebook || {};
    if (localRuntime.Native.Facebook.values)
    {
        return localRuntime.Native.Facebook.values;
    }
    if ('values' in Elm.Native.Facebook)
    {
        return localRuntime.Native.Facebook.values = Elm.Native.Facebook.values;
    }

    var Utils = Elm.Native.Utils.make(localRuntime);
    var Task = Elm.Native.Task.make(localRuntime);

    return localRuntime.Native.Facebook.values = {
        init:   init,
        login:  login,
        logout: logout,
        api: api(Task)
    }

    function api(Task)
    {
        return function (tuple3) {
            var method = tuple3._0, path = tuple3._1, params = tuple3._2;
            return Task.asyncFunction(function (callback) {
                FB.api(path, method, params, function (response) {
                    if (!response) {
                        callback(Task.fail({error: "Unknown Error"}));
                    } else if (response.error) {
                        callback(Task.fail(response.error));
                    } else {
                        callback(Task.succeed(response));
                    }
                })
            })
        }
    }

    function init(options)
    {
        FB.init(options)
    }

    function login()
    {
        FB.login()
    }

    function logout()
    {
        FB.logout()
    }
}
