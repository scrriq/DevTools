#ifndef TASKMANAGER_H
#define TASKMANAGER_H

#include <QAbstractListModel>
#include <QList>
#include "Task.h"

class TaskManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QString currentProjectId READ currentProjectId WRITE setProjectFilter NOTIFY currentProjectIdChanged)
public:
    enum TaskRoles {
        IdRole = Qt::UserRole + 1,
        ProjectIdRole,
        NameRole,
        StatusRole,
        StartDateRole,
        EndDateRole
    };

    explicit TaskManager(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    QString currentProjectId() const;
    Q_INVOKABLE void setProjectFilter(const QString &projectId);

    Q_INVOKABLE void createTask(const QString &projectId,
                                const QString &name,
                                const QString &status,
                                const QString &startDate,
                                const QString &endDate);
    Q_INVOKABLE void toggleStatus(const QString &taskId, const QString &newStatus);
    Q_INVOKABLE void loadFromFile(const QString &filePath);
    Q_INVOKABLE void saveToFile(const QString &filePath) const;
    Q_INVOKABLE void removeTask(const QString &taskId);
    Q_INVOKABLE void removeTasksByProject(const QString &projectId);
signals:
    void currentProjectIdChanged();

private:
    QList<Task> m_tasks;
    QString m_currentProjectId;
};

#endif // TASKMANAGER_H
