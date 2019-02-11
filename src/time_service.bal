import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerinax/kubernetes;

@kubernetes:IstioGateway {}
@kubernetes:IstioVirtualService {}
@kubernetes:Service {
    name: "ballerina-time-service"
}
listener http:Listener timeEP = new(9095);

@kubernetes:Deployment {
    image: "ballerina-time-service",
    name: "ballerina-time-service",
    singleYAML: true
}
@http:ServiceConfig { basePath:"/localtime" }
service time on timeEP {
    @http:ResourceConfig {
        path: "/",
        methods: ["GET"]
    }
    resource function getTime (http:Caller caller, http:Request request) {
        time:Time currentTime = time:currentTime();
        string customTimeString = time:format(currentTime, "yyyy-MM-dd'T'HH:mm:ss");
        json timeJ = { currentTime: customTimeString };
        var responseResult = caller->respond(timeJ);
        if (responseResult is error) {
            log:printError("Error responding back to client");
        }
    }
}