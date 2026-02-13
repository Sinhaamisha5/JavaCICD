# CI/CD Demo Application

A simple Spring Boot REST API to practice CI/CD pipelines with GitHub Actions and Jenkins.

## Application Overview

**Endpoints:**
- `GET /` - Welcome message
- `GET /hello/{name}` - Personalized greeting
- `GET /health` - Health check

## Project Structure
```
cicd-demo/
├── src/
│   ├── main/java/com/example/demo/
│   │   └── DemoApplication.java
│   ├── test/java/com/example/demo/
│   │   └── DemoApplicationTests.java
│   └── resources/
│       └── application.properties
├── .github/workflows/
│   └── ci.yml
├── Dockerfile
├── Jenkinsfile
└── pom.xml
```

## Prerequisites

- Java 17+
- Maven 3.9+
- Docker (optional)
- Git

## Local Development

### Build and Run

```bash
# Build the application
mvn clean package

# Run the application
java -jar target/cicd-demo-1.0.0.jar

# Or use Maven
mvn spring-boot:run
```

### Test the Application

```bash
# Run all tests
mvn test

# Run with coverage
mvn clean test jacoco:report

# View coverage report
open target/site/jacoco/index.html
```

### Code Quality

```bash
# Run checkstyle
mvn checkstyle:check
```

### Docker

```bash
# Build Docker image
docker build -t cicd-demo:latest .

# Run container
docker run -p 8080:8080 cicd-demo:latest

# Test
curl http://localhost:8080
curl http://localhost:8080/hello/World
```

## CI/CD Setup Options

Choose either GitHub Actions OR Jenkins (or both for learning):

---

## Option 1: GitHub Actions (Easiest)

### Setup Steps:

1. **Create GitHub Repository**
```bash
# Initialize git
git init
git add .
git commit -m "Initial commit"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/cicd-demo.git
git branch -M main
git push -u origin main
```

2. **GitHub Actions Runs Automatically**
- Push to `main` or create a PR
- Go to "Actions" tab in your repo
- Watch the pipeline execute!

3. **What the Pipeline Does:**
- ✅ Checkout code
- ✅ Cache Maven dependencies
- ✅ Run Checkstyle linting
- ✅ Build application
- ✅ Run tests with coverage
- ✅ Package JAR
- ✅ Build Docker image
- ✅ Security scan with Trivy

### Viewing Results:
- **Actions tab**: See pipeline runs
- **Artifacts**: Download JAR and Docker image
- **Tests**: View test results in Actions

---

## Option 2: Jenkins on EC2

### EC2 Setup (Ubuntu 22.04)

```bash
# 1. Launch EC2 instance
# - Instance type: t2.medium (minimum)
# - Security groups: 
#   - SSH (22)
#   - Jenkins (8080)
#   - App (8080 if testing locally)

# 2. SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# 3. Install Java 17
sudo apt update
sudo apt install -y openjdk-17-jdk

# 4. Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

# 5. Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# 6. Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# 7. Install Maven
sudo apt install -y maven

# 8. Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Jenkins Configuration

1. **Access Jenkins**: `http://your-ec2-ip:8080`

2. **Initial Setup:**
   - Enter admin password
   - Install suggested plugins
   - Create admin user

3. **Install Additional Plugins:**
   - Dashboard → Manage Jenkins → Plugins
   - Install:
     - Maven Integration
     - Docker Pipeline
     - JaCoCo
     - GitHub Integration

4. **Configure Tools:**
   - Manage Jenkins → Tools
   - **JDK**: Add JDK 17
     - Name: `JDK-17`
     - JAVA_HOME: `/usr/lib/jvm/java-17-openjdk-amd64`
   - **Maven**: Add Maven
     - Name: `Maven-3.9`
     - Install automatically (latest)

5. **Create Pipeline Job:**
   - New Item → Pipeline
   - Name: `cicd-demo-pipeline`
   - Pipeline section:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: Your GitHub repo
     - Branch: `*/main`
     - Script Path: `Jenkinsfile`

6. **Configure GitHub Webhook (Optional):**
   - Jenkins: Job → Configure → Build Triggers → GitHub hook trigger
   - GitHub: Repo Settings → Webhooks → Add webhook
     - URL: `http://your-ec2-ip:8080/github-webhook/`
     - Content type: `application/json`
     - Events: Just the push event

### Running Jenkins Pipeline

**Manual Trigger:**
- Dashboard → Your job → Build Now

**Automatic Trigger:**
- Push to GitHub (if webhook configured)
- Or set up polling: Build Triggers → Poll SCM → `H/5 * * * *`

### Viewing Results:
- **Console Output**: Click build number → Console Output
- **Test Results**: Build → Test Result
- **Coverage**: Build → Coverage Report
- **Artifacts**: Build → Artifacts

---

## Testing Both Pipelines

### Make a Code Change

```bash
# Edit DemoApplication.java
# Change welcome message in home() method

git add .
git commit -m "Update welcome message"
git push origin main
```

**GitHub Actions**: Automatically triggers
**Jenkins**: Triggers via webhook or manually

---

## Common Issues & Solutions

### Jenkins Can't Build Docker Image
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Maven Not Found in Jenkins
- Manage Jenkins → Tools → Maven
- Ensure name matches Jenkinsfile (`Maven-3.9`)

### Tests Failing
```bash
# Run locally first
mvn clean test
# Check test output
```

### Port 8080 Already in Use
```bash
# Find process
sudo lsof -i :8080
# Kill it
sudo kill -9 PID
```

---

## Next Steps

1. ✅ **Practice**: Push code changes, watch pipelines
2. ✅ **Break it**: Introduce test failures, see pipeline fail
3. ✅ **Add features**: New endpoints, more tests
4. ✅ **CD Pipeline**: Deploy to another EC2 instance
5. ✅ **Monitoring**: Add health checks, metrics

---

## Pipeline Comparison

| Feature | GitHub Actions | Jenkins |
|---------|---------------|---------|
| Setup | Instant | Manual (EC2) |
| Cost | Free (public repos) | EC2 costs |
| Maintenance | None | You manage |
| Flexibility | Limited | Full control |
| Learning | Easier | More realistic |

**Recommendation**: Start with GitHub Actions, then try Jenkins for enterprise experience.

---

## Architecture Diagram

```
Developer → GitHub Push
    ↓
GitHub Actions / Jenkins
    ↓
1. Checkout Code
2. Lint (Checkstyle)
3. Build (Maven)
4. Test (JUnit)
5. Package (JAR)
6. Docker Build
7. Security Scan
    ↓
Artifacts Ready for CD
```

---

## Learning Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Maven Guide](https://maven.apache.org/guides/)
- [Spring Boot Testing](https://spring.io/guides/gs/testing-web/)

Happy Learning! 🚀
