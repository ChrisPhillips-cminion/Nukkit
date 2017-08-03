#!/usr/bin/sh
ver=0.08
if [ -z $2 ]; then
  oldVer=$ver;
else
  oldVer=$2;
fi
if [ "$1" == "cleanLocal" ] ; then
 docker rmi  registry.eu-gb.bluemix.net/cminion/minecraft:${oldVer}
elif [ "$1" == "cleanDeploy" ] ; then
  export KUBECONFIG=/Users/chris/.bluemix/plugins/container-service/clusters/mycluster/kube-config-par01-mycluster.yml
  kubectl delete deployment mcnew
  kubectl delete service mcnew
  bx cr image-rm registry.eu-gb.bluemix.net/cminion/minecraft:${oldVer}
elif [ "$1" == "build" ] ; then
  cd ..
  mvn install
  if [ $? -ne 0 ] ; then exit 1;  fi
  cd -
  cp ../target/nuk*jar .
  docker build -t registry.eu-gb.bluemix.net/cminion/minecraft:${ver} .
  docker push registry.eu-gb.bluemix.net/cminion/minecraft:${ver}
elif [ "$1" == "deploy" ] ; then
  export KUBECONFIG=/Users/chris/.bluemix/plugins/container-service/clusters/mycluster/kube-config-par01-mycluster.yml
  cp -v -f deployment.yml  deployment.new.yml
  gsed -i s/VERSION/$ver/ deployment.new.yml
  kubectl create -f  deployment.new.yml
  kubectl create -f service.yml
  sleep 3
  kubectl get service  mcnew
  kubectl get deployment  mcnew

  kubectl logs -f $(kubectl get pods | tail -n1| sed -e s/\ .*//)
  #kubectl run mcnew  --image=registry.eu-gb.bluemix.net/cminion/minecraft:${ver}  --port=8080
  #kubectl expose deployment  mcnew  --type NodePort
elif [ "$1" == "all" ] ; then
  sh docker.sh cleanAll $2

  sh docker.sh build_deploy $2
  if [ $? -ne 0 ] ; then exit 1;  fi

elif [ "$1" == "cleanAll" ] ; then
  sh docker.sh cleanLocal $2
  sh docker.sh cleanDeploy $2
  exit $?
elif [ "$1" == "build_deploy" ] ; then
  sh docker.sh build $2
  if [ $? -ne 0 ] ; then exit 1;  fi

  sh docker.sh deploy $2
  if [ $? -ne 0 ] ; then exit 1;  fi

else
  echo "build deploy all must be passed"
fi
