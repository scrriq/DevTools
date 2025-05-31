#ifndef TASKMANAGER_H
#define TASKMANAGER_H

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include "Task.h"
#include "AuthManager.h"

class TaskManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QString currentProjectId READ currentProjectId WRITE setProjectFilter NOTIFY currentProjectIdChanged)

public:
    explicit TaskManager(QObject *parent = nullptr);

    // Роли для QML
    enum TaskRoles {
        IdRole = Qt::UserRole + 1,
        ProjectIdRole,
        NameRole,
        StatusRole,
        StartDateRole,
        EndDateRole
    };

    QString currentProjectId() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setProjectFilter(const QString &projectId);
    Q_INVOKABLE void createTask(const QString &projectId,
                                const QString &name,
                                const QString &status,
                                const QString &startDate,
                                const QString &endDate);
    Q_INVOKABLE void loadFromFile();
    Q_INVOKABLE void saveToFile() const;
    Q_INVOKABLE void toggleStatus(const QString &taskId, const QString &newStatus);
    Q_INVOKABLE void removeTask(const QString &taskId);
    Q_INVOKABLE void removeTasksByProject(const QString &projectId);

signals:
    void currentProjectIdChanged();
    void tasksUpdated();

private:
    QList<Task> m_tasks;
    QString m_currentProjectId;
    QString fileName() const;
};

#endif // TASKMANAGER_H
