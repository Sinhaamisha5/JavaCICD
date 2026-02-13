# Quick Start Guide - CI/CD Practice

## Choose Your Path

### Path 1: GitHub Actions (Recommended for Beginners)
**Time: 10 minutes**

1. Fork or create this repo on GitHub
2. Push the code
3. Go to "Actions" tab
4. Watch it run automatically!

That's it! Every push will trigger the pipeline.

---

### Path 2: Jenkins on EC2 (Production-Like)
**Time: 30-45 minutes**

#### Step 1: Launch EC2 Instance

**AWS Console:**
- AMI: Ubuntu Server 22.04 LTS
- Instance Type: t2.medium (2 vCPU, 4GB RAM)
- Storage: 20GB
- Security Group:
  ```
  Port 22   (SSH)      - Your IP
  Port 8080 (Jenkins)  - 0.0.0.0/0 (or Your IP)
  Port 8080 (App)      - Your IP (for testing)
  ```
- Create/select key pair

#### Step 2: Setup Jenkins (Easy Way)

```bash
# SSH to your EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Copy the setup script content or download from repo
wget https://raw.githubusercontent.com/YOUR_USERNAME/cicd-demo/main/setup-jenkins-ec2.sh

# Make it executable
chmod +x setup-jenkins-ec2.sh

# Run it
./setup-jenkins-ec2.sh
```

Script installs:
- ✅ Java 17
- ✅ Jenkins
- ✅ Maven
- ✅ Docker
- ✅ Git

#### Step 3: Configure Jenkins

1. **Open Jenkins**: `http://YOUR_EC2_IP:8080`

2. **Initial Setup**:
   - Paste the admin password (shown by script)
   - Install suggested plugins (wait ~5 min)
   - Create admin user:
     - Username: admin
     - Password: your_password
     - Email: your_email

3. **Install Extra Plugins**:
   - Manage Jenkins → Plugins → Available
   - Search and install:
     - ✅ Maven Integration
     - ✅ JaCoCo plugin
     - ✅ Docker Pipeline
   - Restart Jenkins

4. **Configure Tools**:
   - Manage Jenkins → Tools
   - **JDK**:
     - Add JDK
     - Name: `JDK-17`
     - JAVA_HOME: `/usr/lib/jvm/java-17-openjdk-amd64`
     - Uncheck "Install automatically"
   - **Maven**:
     - Add Maven
     - Name: `Maven-3.9`
     - Check "Install automatically"
     - Version: 3.9.5
   - Save

5. **Create Pipeline**:
   - New Item
   - Name: `cicd-demo`
   - Type: Pipeline
   - OK
   - **Pipeline section**:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: `https://github.com/YOUR_USERNAME/cicd-demo.git`
     - Branch: `*/main`
     - Script Path: `Jenkinsfile`
   - Save

6. **Run Pipeline**:
   - Click "Build Now"
   - Watch it execute!

#### Step 4: Setup Auto-Trigger (Optional)

**In Jenkins job:**
- Configure → Build Triggers
- Check "GitHub hook trigger for GITScm polling"
- Save

**In GitHub repo:**
- Settings → Webhooks → Add webhook
- Payload URL: `http://YOUR_EC2_IP:8080/github-webhook/`
- Content type: `application/json`
- Events: Just the push event
- Add webhook

Now every push triggers the build!

---

## Test Your Pipeline

### Make a Simple Change

```bash
# Edit src/main/java/com/example/demo/DemoApplication.java
# Change line 14 to:
return "Welcome to MY Awesome CI/CD Demo!";

# Commit and push
git add .
git commit -m "Update welcome message"
git push origin main
```

**Watch:**
- GitHub Actions: Actions tab
- Jenkins: Dashboard → Your job → Last build

### Break It (Learn From Failures)

```bash
# Edit DemoApplicationTests.java
# Change line 23 to expect wrong text:
.andExpect(content().string("Wrong text"));

# Push it
git add .
git commit -m "Break the test"
git push origin main
```

Pipeline will fail! This is good - you'll see how CI catches bugs.

**Fix it:**
```bash
# Revert the change
git revert HEAD
git push origin main
```

---

## Verify Everything Works

### Local Test First
```bash
# Build
mvn clean package

# Run
java -jar target/cicd-demo-1.0.0.jar

# In another terminal, test:
curl http://localhost:8080
curl http://localhost:8080/hello/YourName
curl http://localhost:8080/health
```

### Check Pipeline Artifacts

**GitHub Actions:**
- Actions → Your workflow → Artifacts
- Download `application-jar`

**Jenkins:**
- Build → Artifacts
- Download JAR file

### Test Docker Image

**Build locally:**
```bash
docker build -t cicd-demo:test .
docker run -p 8080:8080 cicd-demo:test
curl http://localhost:8080
```

---

## Troubleshooting

### Jenkins Won't Start
```bash
sudo systemctl status jenkins
sudo journalctl -u jenkins -n 50
```

### Can't Access Jenkins on Port 8080
- Check EC2 Security Group allows port 8080
- Check Jenkins is running: `sudo systemctl status jenkins`

### Pipeline Fails at Docker Build
```bash
# On EC2:
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
# Wait 2 minutes, try again
```

### Maven Build Fails
- Check Java version: `java -version` (should be 17)
- Check Maven: `mvn -version`
- In Jenkins tools, verify JDK-17 and Maven-3.9 names match Jenkinsfile

### Tests Fail
```bash
# Run locally to debug
mvn clean test
# Check the test output
```

---

## What You're Learning

✅ **CI Concepts:**
- Automated builds
- Automated testing
- Code quality checks
- Artifact generation

✅ **Tools:**
- GitHub Actions (cloud CI)
- Jenkins (self-hosted CI)
- Maven (build tool)
- Docker (containerization)

✅ **Best Practices:**
- Pipeline as code
- Fail fast
- Automated testing
- Artifact versioning

---

## Next Steps

1. **Add More Tests**: Write more unit tests
2. **Add Integration Tests**: Test with real database
3. **Static Analysis**: Add SonarQube
4. **Deploy**: Create CD pipeline to deploy to another EC2
5. **Monitoring**: Add Prometheus/Grafana
6. **Notifications**: Slack/Email on build failure

---

## Cost Optimization (EC2)

**Free Tier**: t2.micro (1 vCPU, 1GB RAM)
- Will work but slower
- Change instance type to t2.micro
- Good for learning, less good for heavy builds

**When Done Practicing**:
```bash
# Stop instance (keeps storage, pay for storage only)
aws ec2 stop-instances --instance-ids YOUR_INSTANCE_ID

# Or terminate completely (deletes everything, no charge)
aws ec2 terminate-instances --instance-ids YOUR_INSTANCE_ID
```

---

## Success Checklist

- [ ] Code compiles
- [ ] All tests pass  
- [ ] Pipeline runs successfully
- [ ] Can download JAR artifact
- [ ] Docker image builds
- [ ] Can trigger pipeline by pushing code
- [ ] Can see test results and coverage
- [ ] Understand what each pipeline stage does

---

**Need Help?**
- Check the main README.md for detailed docs
- Review Jenkins Console Output for errors
- Check GitHub Actions logs
- Google specific error messages

**You've got this! 🚀**
