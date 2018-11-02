import ballerina/http;
import ballerina/io;
import ballerina/time;
import ballerinax/kubernetes;

@kubernetes:Ingress {
    name: "ballerina-time-service",
    path: "/localtime",
    ingressClass: "istio"
}
@kubernetes:Service {
    serviceType: "NodePort",
    name: "ballerina-time-service"
}
endpoint http:Listener listener {
    port: 9095
};

@kubernetes:Deployment {
    image: "ballerina-time-service",
    name: "ballerina-time-service",
    singleYAML: true
}
@http:ServiceConfig { basePath:"/localtime" }
service<http:Service> time bind listener {
    @http:ResourceConfig {
        path: "/",
        methods: ["GET"]
    }
    getTime (endpoint caller, http:Request request) {
        http:Response response = new;
        time:Time currentTime = time:currentTime();
        string customTimeString = currentTime.format("yyyy-MM-dd'T'HH:mm:ss");

        json timeJ = {currentTime : customTimeString };
        response.setJsonPayload(timeJ);
        _ = caller -> respond(response);
    }
}
