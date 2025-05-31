// AuthManager.h
#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QString>
#include <QList>
#include <QJsonObject>

struct UserRecord {
    QString id;
    QString login;
    QString name;
    QByteArray passwordHash;
    QString description;
    QString preferences;
    QString avatarPath;
    QString projectsFile;
    QString tasksFile;
};

class AuthManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isAuthenticated      READ isAuthenticated      NOTIFY userChanged)
    Q_PROPERTY(QString currentUserId     READ currentUserId        NOTIFY userChanged)
    Q_PROPERTY(QString userName          READ userName             NOTIFY userChanged)
    Q_PROPERTY(QString userDescription   READ userDescription      NOTIFY userChanged)
    Q_PROPERTY(QString userPreferences   READ userPreferences      NOTIFY userChanged)
    Q_PROPERTY(QString userAvatarPath    READ userAvatarPath       NOTIFY userChanged)

public:
    static AuthManager& instance();

    Q_INVOKABLE bool    registerUser(const QString& login,
                                  const QString& name,
                                  const QString& password);
    Q_INVOKABLE bool    login(const QString& login,
                           const QString& password);
    Q_INVOKABLE void    logout();
    Q_INVOKABLE void    updateUserProfile(const QString& description,
                                       const QString& preferences);
    Q_INVOKABLE void    updateUserAvatar(const QString& avatarPath);

    bool    isAuthenticated() const;
    QString currentUserId()   const;
    QString userName()        const;
    QString userDescription() const;
    QString userPreferences() const;
    QString userAvatarPath()  const;

signals:
    void userChanged();

private:
    explicit AuthManager(QObject* parent = nullptr);

    void loadUsers();
    void saveUsers() const;
    QByteArray hashPassword(const QString& password) const;

    QList<UserRecord> m_users;
    QString m_currentUserId;
    QString m_userName;
    QString m_userDescription;
    QString m_userPreferences;
    QString m_userAvatarPath;
};

#endif // AUTHMANAGER_H
