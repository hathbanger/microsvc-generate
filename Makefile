ORIGINAL_PROJECT_NAME := "microsvc-base"
ORIGINAL_PACKAGE_NAME := "microsvc"

endpoint:
	read -p "Enter endpoint uppercase name: " capitalizedEndpoint; \
	read -p "Enter endpoint lowercase name: " lowercaseEndpoint; \
	read -p "Enter package name: " packageName;\
	grep -rl Bar templates | xargs sed -i.bak "s/Bar/$$capitalizedEndpoint/g"; \
	grep -rl bar templates | xargs sed -i.bak "s/bar/$$lowercaseEndpoint/g"; \
	REQUEST_MODEL=$$capitalizedEndpoint; REQUEST_MODEL+="Request"; \
	RESPONSE_MODEL=$$capitalizedEndpoint; RESPONSE_MODEL+="Response"; \
	cat templates/service.txt >> ../pkg/$$packageName/$$lowercaseEndpoint.go; \
	echo "package $$packageName" >> ../pkg/$$packageName/$$lowercaseEndpoint.go; \
	sed -i "" "s/package main//g" ../pkg/$$packageName/models/$$lowercaseEndpoint.go;\
	echo "package models" > ../pkg/$$packageName/models/$$lowercaseEndpoint.go; \
	cat templates/models/request.json | gojson -name=$$REQUEST_MODEL >> ../pkg/$$packageName/models/$$lowercaseEndpoint.go; \
	cat templates/models/response.json | gojson -name=$$RESPONSE_MODEL >> ../pkg/$$packageName/models/$$lowercaseEndpoint.go; \
	PATTERN='// interfaceDeclaration.txt' ./templater.awk templates/interfaceDeclaration.txt ../pkg/$$packageName/service.go > temp && mv temp ../pkg/$$packageName/service.go; \
	PATTERN='// decodeRequest.txt' ./templater.awk templates/decodeRequest.txt ../pkg/$$packageName/transport.go > temp && mv temp ../pkg/$$packageName/transport.go; \
	PATTERN='// transport.txt' ./templater.awk templates/transport.txt ../pkg/$$packageName/transport.go > temp && mv temp ../pkg/$$packageName/transport.go; \
	PATTERN='// endpoints.txt' ./templater.awk templates/endpoints.txt ../pkg/$$packageName/endpoints.go > temp && mv temp ../pkg/$$packageName/endpoints.go; \
	PATTERN='// instrumenting.txt' ./templater.awk templates/instrumenting.txt ../pkg/$$packageName/instrumenting.go > temp && mv temp ../pkg/$$packageName/instrumenting.go; \
	PATTERN='// test.txt' ./templater.awk templates/test.txt ../test/service_test.go > temp && mv temp ../test/service_test.go

service:
	read -p "Create a new service? (y/n) " newService; \
	echo $$newService; \
    if [ $$newService != y ]; then \
		exit 0; \
	fi; \
	read -p "New svc name? " serviceName; \
	read -p "New package name? " packageName; \
	git clone https://github.com/hathbanger/microsvc-base ../$$serviceName; \
	rm -rf ../$$serviceName/.git; \
	grep -rl "fmt.Println(\"TEMPORARY API PRINT\", api)" ../$$serviceName | xargs sed -i "" "s/fmt.Println(\"TEMPORARY API PRINT\", api)//g"; \
	grep -rl $(ORIGINAL_PROJECT_NAME) ../$$serviceName | xargs sed -i "" "s/$(ORIGINAL_PROJECT_NAME)/$$serviceName/g"; \
	mv ../$$serviceName/cmd/$(ORIGINAL_PROJECT_NAME).go ../$$serviceName/cmd/$$serviceName.go; \
	mv ../$$serviceName/pkg/$(ORIGINAL_PACKAGE_NAME) ../$$serviceName/pkg/$$packageName; \
	grep -rl $(ORIGINAL_PACKAGE_NAME) ../$$serviceName | xargs sed -i "" "s/$(ORIGINAL_PACKAGE_NAME)/$$packageName/g";
	
