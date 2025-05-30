#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QStandardPaths>
#include <QDir>
#include "Project.h"
#include "AuthManager.h"

class ProjectManager : public QAbstractListModel {
    Q_OBJECT
public:
    enum ProjectRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        StatusRole,
        StartDateRole,
        EndDateRole
    };

    explicit ProjectManager(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void createProject(const QString &name,
                                   const QString &status,
                                   const QString &startDate,
                                   const QString &endDate);
    Q_INVOKABLE void loadFromFile();
    Q_INVOKABLE void saveToFile() const;
    Q_INVOKABLE QVariantMap getById(const QString &id) const;
    Q_INVOKABLE void updateStatus(const QString &id, const QString &newStatus);
    Q_INVOKABLE void removeProject(const QString &id);

signals:
    void projectsUpdated();

private:
    QList<Project> m_projects;
    QString fileName() const;
};

#endif // PROJECTMANAGER_H
