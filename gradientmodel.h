#pragma once
#include <QObject>
#include <QColor>
#include <QVector>

struct Stop { qreal position; QColor color; };

class GradientModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(int angle READ angle WRITE setAngle NOTIFY angleChanged)
    Q_PROPERTY(QVector<QObject*> stops READ stops NOTIFY stopsChanged)
public:
    explicit GradientModel(QObject* parent = nullptr);
    QString type() const;
    void setType(const QString &);
    int angle() const;
    void setAngle(int);
    QVector<QObject*> stops() const;
    Q_INVOKABLE void setStop(int index, qreal pos, const QColor &col);
signals:
    void typeChanged();
    void angleChanged();
    void stopsChanged();
private:
    QString m_type {"Linear"};
    int     m_angle{90};
    QVector<QObject*> m_stops;
};
