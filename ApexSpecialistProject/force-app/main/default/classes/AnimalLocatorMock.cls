@isTest
global class AnimalLocatorMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        // Return different responses based on ID in endpoint
        if (req.getEndpoint().endsWith('/1')) {
            res.setStatusCode(200);
            res.setBody('{"animal": {"id": 1, "name": "mock lion", "eats": "meat", "says": "roar"}}');
        } else if (req.getEndpoint().endsWith('/2')) {
            res.setStatusCode(200);
            res.setBody('{"animal": {"id": 2, "name": "mock rabbit", "eats": "carrots", "says": "squeak"}}');
        } else {
            res.setStatusCode(404);
            res.setBody('{"error":"not found"}');
        }

        return res;
    }
}