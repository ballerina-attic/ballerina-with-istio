import ballerina/http;
import ballerina/time;
import ballerinax/kubernetes;

@kubernetes:IstioGateway {}
@kubernetes:IstioVirtualService {}
@kubernetes:Service {
    name: "ballerina-time-service"
}
listener http:Server timeEP = new http:Server(9095);

@kubernetes:Deployment {
    image: "ballerina-time-service",
    name: "ballerina-time-service",
    singleYAML: true
}
@http:ServiceConfig { basePath: "/localtime" }
service time on timeEP {
    @http:ResourceConfig {
        path: "/",
        methods: ["GET"]
    }
    resource function getTime (http:Caller caller, http:Request request) {
        http:Response response = new;
        time:Time currentTime = time:currentTime();
        string customTimeString = currentTime.format("yyyy-MM-dd'T'HH:mm:ss");

        json timeJ = { currentTime: customTimeString };
        response.setJsonPayload(timeJ);
        _ = caller -> respond(response);
    }
}
