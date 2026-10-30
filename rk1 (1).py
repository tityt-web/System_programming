from operator import itemgetter


class Conductor:
    def __init__(self, id, fio, salary, orch_id):
        self.id = id
        self.fio = fio
        self.salary = salary
        self.orch_id = orch_id


class Orchestra:
    def __init__(self, id, name):
        self.id = id
        self.name = name


class ConductorOrchestra:
    def __init__(self, orch_id, cond_id):
        self.orch_id = orch_id
        self.cond_id = cond_id


orchestras = [
    Orchestra(1, 'Академический симфонический оркестр'),
    Orchestra(2, 'Камерный оркестр'),
    Orchestra(3, 'Астраханский филармонический оркестр'),
    Orchestra(4, 'Джазовый оркестр'),
]

conductors = [
    Conductor(1, 'Орлов', 120000, 1),
    Conductor(2, 'Белкин', 95000, 1),
    Conductor(3, 'Морозов', 80000, 2),
    Conductor(4, 'Зайцев', 70000, 3),
    Conductor(5, 'Комаров', 110000, 3),
    Conductor(6, 'Лебедев', 60000, 4),
]

conductors_orchestras = [
    ConductorOrchestra(1, 1),
    ConductorOrchestra(1, 2),
    ConductorOrchestra(1, 4),
    ConductorOrchestra(2, 3),
    ConductorOrchestra(3, 4),
    ConductorOrchestra(3, 5),
    ConductorOrchestra(3, 1),
    ConductorOrchestra(4, 6),
    ConductorOrchestra(4, 3),
]


def main():
    one_to_many = [(c.fio, c.salary, o.name)
                   for o in orchestras
                   for c in conductors
                   if c.orch_id == o.id]

    many_to_many_temp = [(o.name, co.orch_id, co.cond_id)
                         for o in orchestras
                         for co in conductors_orchestras
                         if o.id == co.orch_id]

    many_to_many = [(c.fio, c.salary, orch_name)
                    for orch_name, orch_id, cond_id in many_to_many_temp
                    for c in conductors if c.id == cond_id]

    print('Задание Д1')
    res_1 = [(fio, orch_name) for fio, _, orch_name in one_to_many if fio.endswith('ов')]
    for fio, orch_name in res_1:
        print(f'{fio} - {orch_name}')

    print('\nЗадание Д2')
    res_2_unsorted = []
    for o in orchestras:
        salaries = [sal for _, sal, orch_name in one_to_many if orch_name == o.name]
        if len(salaries) > 0:
            res_2_unsorted.append((o.name, sum(salaries) / len(salaries)))
    res_2 = sorted(res_2_unsorted, key=itemgetter(1), reverse=True)
    for orch_name, avg in res_2:
        print(f'{orch_name}: {avg:.2f}')

    print('\nЗадание Д3')
    res_3 = {}
    for o in orchestras:
        if o.name.startswith('А'):
            res_3[o.name] = [fio for fio, _, orch_name in many_to_many if orch_name == o.name]
    for orch_name, fios in res_3.items():
        print(f'{orch_name}: {", ".join(fios)}')


if __name__ == '__main__':
    main()
