#include "gradientmodel.h"
#include <QVariant>

GradientModel::GradientModel(QObject* parent)
    : QObject(parent)
{
    // создаем 4 стопа по-умолчанию
    m_stops.reserve(4);
    for (int i = 0; i < 4; ++i)
        m_stops.append(new QObject(this));
    emit stopsChanged();
}

QString GradientModel::type() const { return m_type; }
void GradientModel::setType(const QString &t) {
    if (m_type != t) { m_type = t; emit typeChanged(); }
}

int GradientModel::angle() const { return m_angle; }
void GradientModel::setAngle(int a) {
    if (m_angle != a) { m_angle = a; emit angleChanged(); }
}

QVector<QObject*> GradientModel::stops() const { return m_stops; }

void GradientModel::setStop(int idx, qreal pos, const QColor &col) {
    if (idx < 0 || idx >= m_stops.size()) return;
    m_stops[idx]->setProperty("position", QVariant::fromValue(pos));
    m_stops[idx]->setProperty("color",    QVariant::fromValue(col));
    emit stopsChanged();
}


