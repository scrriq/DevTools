#include "AuthManager.h"
#include <QFile>
#include <QStandardPaths>
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUuid>
#include <QCryptographicHash>
#include <QDebug>

AuthManager& AuthManager::instance() {
    static AuthManager inst;
    return inst;
}

AuthManager::AuthManager(QObject* parent)
    : QObject(parent)
{
    loadUsers();
}

void AuthManager::loadUsers() {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QFile file(path + "/users.json");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "[AuthManager] users.json not found, starting new";
        return;
    }
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonArray arr = doc.object().value("users").toArray();
    for (auto v : arr) {
        QJsonObject obj = v.toObject();
        UserRecord r;
        r.id           = obj.value("id").toString();
        r.login        = obj.value("login").toString();
        r.name         = obj.value("name").toString();
        r.passwordHash = QByteArray::fromHex(obj.value("passwordHash").toString().toUtf8());
        r.description  = obj.value("description").toString();
        r.preferences  = obj.value("preferences").toString();
        r.avatarPath   = obj.value("avatarPath").toString();
        r.projectsFile = obj.value("projectsFile").toString();
        r.tasksFile    = obj.value("tasksFile").toString();
        m_users.append(r);
    }
}

void AuthManager::saveUsers() const {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QFile file(path + "/users.json");
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "[AuthManager] Cannot save users.json";
        return;
    }

    QJsonArray arr;
    for (auto &r : m_users) {
        QJsonObject obj;
        obj["id"]           = r.id;
        obj["login"]        = r.login;
        obj["name"]         = r.name;
        obj["passwordHash"] = QString(r.passwordHash.toHex());
        obj["description"]  = r.description;   // записываем
        obj["preferences"]  = r.preferences;   // записываем
        obj["avatarPath"]   = r.avatarPath;    // записываем
        obj["projectsFile"] = r.projectsFile;
        obj["tasksFile"]    = r.tasksFile;
        arr.append(obj);
    }
    QJsonObject root;
    root["users"] = arr;
    file.write(QJsonDocument(root).toJson());
    file.close();
}

QByteArray AuthManager::hashPassword(const QString& password) const {
    return QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
}

bool AuthManager::registerUser(const QString& login, const QString& name, const QString& password) {
    for (auto &r : m_users) {
        if (r.login.compare(login, Qt::CaseInsensitive) == 0)
            return false;
    }
    UserRecord u;
    u.id           = QUuid::createUuid().toString(QUuid::WithoutBraces);
    u.login        = login;
    u.name         = name;
    u.passwordHash = hashPassword(password);
    u.description  = "";
    u.preferences  = "";
    u.avatarPath   = "";
    u.projectsFile = QString("projects_%1.json").arg(u.id);
    u.tasksFile    = QString("tasks_%1.json").arg(u.id);
    m_users.append(u);
    saveUsers();

    m_currentUserId     = u.id;
    m_userName          = u.name;
    m_userDescription   = u.description;
    m_userPreferences   = u.preferences;
    m_userAvatarPath    = u.avatarPath;
    emit userChanged();
    return true;
}

bool AuthManager::login(const QString& login, const QString& password) {
    QByteArray h = hashPassword(password);
    for (auto &r : m_users) {
        if (r.login == login && r.passwordHash == h) {
            m_currentUserId     = r.id;
            m_userName          = r.name;
            m_userDescription   = r.description;
            m_userPreferences   = r.preferences;
            m_userAvatarPath    = r.avatarPath;
            emit userChanged();
            return true;
        }
    }
    return false;
}

void AuthManager::logout() {
    m_currentUserId.clear();
    m_userName.clear();
    m_userDescription.clear();
    m_userPreferences.clear();
    m_userAvatarPath.clear();
    emit userChanged();
}

void AuthManager::updateUserProfile(const QString& description, const QString& preferences) {
    for (auto& r : m_users) {
        if (r.id == m_currentUserId) {
            r.description = description;
            r.preferences = preferences;
            m_userDescription = description;
            m_userPreferences = preferences;
            saveUsers();
            emit userChanged();
            break;
        }
    }
}

void AuthManager::updateUserAvatar(const QString& avatarPath) {
    for (auto& r : m_users) {
        if (r.id == m_currentUserId) {
            r.avatarPath = avatarPath;
            m_userAvatarPath = avatarPath;
            saveUsers();
            emit userChanged();
            break;
        }
    }
}

bool AuthManager::isAuthenticated() const {
    return !m_currentUserId.isEmpty();
}

QString AuthManager::currentUserId() const {
    return m_currentUserId;
}

QString AuthManager::userName() const {
    return m_userName;
}

QString AuthManager::userDescription() const {
    return m_userDescription;
}

QString AuthManager::userPreferences() const {
    return m_userPreferences;
}

QString AuthManager::userAvatarPath() const {
    return m_userAvatarPath;
}
