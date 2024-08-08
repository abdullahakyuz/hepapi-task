# Basit Flask Uygulaması

Bu uygulama Python Flask uygulamasıdır. Uygulamanın verilerinin saklanması için MongoDB kullanılmıştır. Uygulama Windows 11 işletim sistemi üzerinde oluşturulmuştur.

### Ön Hazırlık

İlk olarak bilgisayarınızda uygulamayı çalıştırmak için ihtiyacınız olan uygulamaları kurun.

- [Vs Code indir](https://code.visualstudio.com/)
- [Docker Desktop İndir](https://www.docker.com/products/docker-desktop/)
- [Minikube İndir](https://minikube.sigs.k8s.io/docs/)
- [Java İndir](https://www.oracle.com/tr/java/technologies/downloads/#java17) (Uygulama JRE 17'de sorunsuz çalışmakta)
- [Jenkins İndir](https://www.jenkins.io/)
- [Python İndir](https://www.python.org/downloads/) (Kurulum sırasında Add PATH işaretlemeyi unutmayın)
- [MongoDB İndir](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-windows/)


Python Sanal Ortam Kurulumu

```
python -m venv myenv
.\myenv\Scripts\activate
```
Flask , Flask-WTF ve Pymongo'nun Windows'a kurulumu

```
pip install Flask Flask-WTF pymongo
```

It will install Flask, Flask-WTF, and PyMongo.

### Uygulamayı çalıştırma

MongoDB Windows Uygulamasını çalıştırdığınızdan emin olun. Ardından uygulamanın dosyalarının bulunduğu dizinde aşağıdaki komut ile uygulamayı çalıştırın.

```
$ python run.py
```

Tarayıcınızı açın ve arama kısmına `localhost:5000` yazın. Uygulamanın çalıştığını görüntüleyin.

### Uygulamayı Docker ile çalıştırma

`##Docker Desktop uygulamasının açık olduğundan emin olun.`

Dockerfile ile kendi imajınızı oluşturabilirsiniz. Kendi imajınızı oluşturup kullanmak istemiyorsanız bir alttaki adıma geçebilirsiniz.

Kendi imajınızı oluşturmak için Dockerfile'ı çalıştırmadan önce aşağıdaki dosyaları farklı bir konuma taşıyın. Dockerfile için oluşturulacak imajın içerisinde olmasını istemediğimiz dosyaları ayrı yere taşıyıp sonra aynı dizine bırakabiliriz. Aşağıdaki dosyaları ilk önce başka bir dizine taşıyın

`cleanup.ps1 >deploy.ps1 docker-compose.yml flask-deploy.yaml Jenkinsfile mongodb-deploy.yaml`

ve Dockerfile ile imaj oluşturun.

```
docker build -t flask-app .
```
Docker imajınız oluştuktan sonra dosyaları eski yerine taşıyabilirsiniz. Dockerfile ile oluşturduğunuz imajı docker login olduktan sonra kendi dockerhub hesabınıza yükleyebilir ve uygulama imajı olarak kendi imajınızı kullanabilirsiniz.

Docker compose ile uygulamayı çalıştırmak için aşağıdaki komutu girdiğinizde uygulama 2 docker konteynerinde oluşacaktır. Uygulamayı `localhost:5000` ile görüntüleyebilirsiniz. MongoDB `localhost:27017` de çalışmaktadır. Ancak MongoDB'yi görüntülemek istediğinizde `It looks like you are trying to access MongoDB over HTTP on the native driver port.` mesajı görmelisiniz. Bunu görüyorsanız hem uygulamanız hem MongoDB bağlantısı çalışmaktadır. Uygulamaya veri girmeyi deneyin.

### Uygulamayı Kubernetes ile çalıştırma

`##Docker Desktop uygulamasının açık olduğundan ve minikube u başlattığınızdan emin olun.`

Kubernetes ile uygulamayı ayağa kaldırmak için aşağıdaki komutu girmeniz yeterlidir.

```
kubectl apply -f .
```

Uygulamanın çalıştığından emin olmak için komut ekranına şu komutu yazın


```
minikube ip
```

Alacağınız ip adresini kopyalayın ve `30002` ekleyin. `192.168.1.1:30002` gibi.

Kubernetes manifest dosyalarınızın içeriği:

`flask-depoloy.yaml` dosyası ile birlikte uygulamanız 1 pod ile ayağa kalkacak ve belirlediğimiz imajı dockerhub'dan kuracaktır. Servis objesi uygulamanın NodePort tipi servisle 30002 portundan yayın yapmasını sağlayacaktır. Uygulamanın MongoDB'ye bağlanması için gerekli olan çevresel değişkenler ayrı bir secret file'a yazılmamış uygulama içine açık şekilde yazılmıştır.

`mongodb-deploy.yaml` dosyası mongobdb'yi 4.4 imajından kurulumunu sağlayacaktır. Mongodb 27017 portundan yayın yapmaktadır. Servis tipini ClusterIP yaparak veritabanına dış dünyadan erişimi kısıtlayıp sadece cluster içinde bulunan uygulamaların erişimini aktif hale getirmiş bulunmaktayız.

`mongodb-pv.yaml` mongodb'nin veritabanında biriktirdiği saklamak için oluşturulmuştur.

`mongodb-pvc.yaml` oluşturulan 5 GB'lık volume'den 5 GB'lık kısmın tamamının MongoDB uygulamasına bağlanmasını sağlama talebidir. PVC objesinin öncelikli olarak PV objesine ve ardından MongoDB'ye bağlanması sağlanmış böylelikle uygulamamız dursa dahi verilerimiz MongoDB içerisinde oluşturulan /data/mongodb yolunda saklanacaktır.

Uygulamanız çalışıyor tebrikler !

### Uygulamayı Jenkins ile çalıştırma

`##Docker Desktop uygulamasının açık olduğundan ve minikube u başlattığınızdan emin olun.`

Jenkinsfile, `deploy.ps1` ve `cleanup.ps1` dosyalarına göre yazılmıştır. Jenkinsfile her iki dosyayı içerir. Uygulamanız önce çalıştırılacak ve tarayıcınızda bir sekmede görünüleyeceksiniz. Ardından 1 dakika sonra uygulamanız sonlandırılacaktır. Jenkinsfile 1 dakika uygulamayı ayağa kaldırıp ardından uygulamayı kaldıracak şekilde hazırlanmıştır.

Jenkins'de ihtiyacınız olacak plugin'leri kurun. Bunlar `Docker plugin` `Kubernetes CLI plugin` `Kubernetes plugin`

Jenkins'de Kubernetes yetkilendirme işlemlerini yapmalısınız. Jenkins ile Minikube Kubernetes Credintials'ını hazırlamak için Tutorial'ı izleyin. 

[Minikube Jenkins Yetkilendirmesi](https://www.youtube.com/watch?v=fodA9rM5xoo)

`##Jenkins pipeline ile uygulamayı çalıştırma.`

Bir pipeline oluşturun ve Jenkinsfile'da yazan metnin tamamını kopyalayın. Bunun yerine Jenkinsfile'ı da kullanabilirsiniz. Ancak Github credential olduğundan yada Github reponuzun public olduğundan emin olun. Böylelikle Pipeline script'i yerine Jenkinsfile ile de pipeline hazırlayabilirsiniz.

`##Jenkinsfile'da 5. satırda bulunan KUBECONFIG değerinini kendi bilgisayarınızda bulunan kullanıcı adına göre değiştirin aksi halde Jenkinsfile Kubernetes config dosyasını bulamadığı için çalışmayacaktır.`





`##Jenkins freestyle project ile uygulamayı çalıştırma.`

Komut satırında Github SCM ile erişebildiğiniz `cleanup.ps1` dosyasınız çalıştırdığınızda uygulama çalışacaktır. `cleanup1.ps1` dosyasını çalıştırdığınızda ise uygulama sonlandırılacaktır.
