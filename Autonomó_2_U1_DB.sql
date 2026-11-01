Create database DBUniv;
Go

Use DBUniv;
Go

Create table Estudiantes (
	estudiante_id int identity(1,1) primary key,
	nombre varchar(60) not null,
	cedula varchar(10) not null unique,
	facultad varchar(100) not null
);

Create table Asignaturas (
	asignatura_id int identity(1,1) primary key,
	nombre_materia varchar(100) not null,
	docente varchar(100),
	cupos_disponibles int check (cupos_disponibles >= 0)
);

Create table Registros_Matricula (
	registro_id int identity(100,1) primary key,
	estudiante_id int not null,
	asignatura_id int not null,
	fecha_registro datetime not null default getdate(),
	estado varchar(20) not null
		check (estado in ('confirmada', 'pendiente')),

	Constraint fk_registro_estudiante
		Foreign key (estudiante_id)
		References Estudiantes(estudiante_id),

	Constraint fk_registro_asignatura
		Foreign key (asignatura_id)
		References Asignaturas(asignatura_id)
);

Create table Auditoria_Matriculas (
	auditoria_id int identity(1,1) primary key,
	registro_id int not null,
	accion varchar(40) not null,
		check (accion in ('Matriculación', 'Retiro')),
	usuario varchar(100) not null,
	fecha datetime not null default getdate(),
);

Create table Historial_Cupos (
	historial_id int identity(1,1) primary key,
	asignatura_id int not null,
	cupo_anterior int,
	cupo_nuevo int,
	fecha_cambio datetime not null default getdate()
);


Insert into Estudiantes (nombre, cedula, facultad)
Values
('Thiago Mendoza', '0341517440', 'Facultad de Ciencias Económicas'),
('Mateo Serrano', '9819777591', 'Facultad de Ciencias Sociales'),
('Valentina Castillo', '6465363402', 'Facultad de Ingeniería'),
('Isabella Paredes', '0854497677', 'Facultad de Derecho'),
('Facundo Palacios', '9125712130', 'Facultad de Ciencias Naturales'),
('Lautaro Guevara', '1226162386', 'Facultad de Arquitectura y Diseño'),
('Camila Benítez', '0773956485', 'Facultad de Ciencias Naturales'),
('Jerónimo Miranda', '6892644265', 'Facultad de Ciencias Económicas'),
('Emiliano Salazar', '3343168862', 'Facultad de Ciencias de la Salud');

Select * From Estudiantes;

Insert into Asignaturas (nombre_materia, docente, cupos_disponibles)
Values
('Base de Datos', 'Dr. Carlos Méndez', 25),
('Derecho Constitucional I', 'Dra. Elena Rostova', 15),
('Macroeconomía Avanzada', 'Ing. Jorge Valenzuela', 30),
('Diseño de Interfaces (UX/UI)', 'Msc. Natalia Rossi', 12),
('Anatomía Humana II', 'Dr. Andrés Borja', 8),
('Introducción a la Psicología', 'Lic. Valeria Gomez', 40),
('Álgebra Lineal', 'Msc. Ricardo Solís', 22),
('Derecho Penal General', 'Abg. Roberto Novoa', 18),
('Microeconomía', 'Eco. Silvia Paredes', 35);

Select * From Asignaturas;

Insert into Registros_Matricula (estudiante_id, asignatura_id, fecha_registro, estado) 
Values
(1, 3, '2026-10-15 08:30:00', 'confirmada'),  -- Thiago Mendoza en Macroeconomía Avanzada
(3, 1, '2026-10-15 09:15:00', 'confirmada'),  -- Valentina Castillo en Bases de Datos
(4, 2, '2026-10-15 10:00:00', 'pendiente'),   -- Isabella Paredes en Derecho Constitucional I
(9, 5, '2026-10-16 07:45:00', 'confirmada'),  -- Emiliano Salazar en Anatomía Humana II
(5, 7, '2026-10-16 11:20:00', 'confirmada'),  -- Facundo Palacios en Álgebra Lineal
(6, 4, '2026-10-17 14:10:00', 'pendiente'),   -- Lautaro Guevara en Diseño de Interfaces (UX/UI)
(8, 9, '2026-10-17 15:00:00', 'confirmada'),  -- Jerónimo Miranda en Microeconomía
(2, 6, '2026-10-18 08:00:00', 'confirmada'),  -- Mateo Serrano en Introducción a la Psicología
(7, 7, '2026-10-18 09:35:00', 'pendiente');   -- Camila Benítez en Álgebra Lineal

Select * From Registros_Matricula;

-- Transaccion A; Uso del commit

Select asignatura_id, nombre_materia, cupos_disponibles
From Asignaturas
Where asignatura_id = 1;

Begin Transaction;

Insert into Registros_Matricula (estudiante_id, asignatura_id, fecha_registro, estado)
Values
(1,1, '2026-10-18 09:35:00', 'confirmada');

Update Asignaturas
Set cupos_disponibles = cupos_disponibles - 1
Where asignatura_id = 1;

Commit;

Select * From Registros_Matricula
Where estudiante_id = 1
	And asignatura_id = 1;


-- Transacción B: Uso de Rollback

Begin Transaction;

Insert into Registros_Matricula (estudiante_id, asignatura_id, fecha_registro, estado)
Values
(2,1, GETDATE(), 'confirmada');

Update Asignaturas
Set cupos_disponibl = cupos_disponibles - 1
Where asignatura_id = 2;

Select * From Registros_Matricula
Where estudiante_id = 2
	And asignatura_id = 2;

Rollback;

Select * From Registros_Matricula
Where estudiante_id = 2
	And asignatura_id = 2;

Select * From Asignaturas
Where asignatura_id = 2;


-- Transacción C: Matrícula Multimateria

Select asignatura_id, nombre_materia, cupos_disponibles
From Asignaturas
Where asignatura_id In (1,2);

Begin Transaction;

-- Materia 1 (Exito)
Update Asignaturas
Set cupos_disponibles = cupos_disponibles - 1
Where asignatura_id = 1;

-- Materia 2 (Exito)
Update Asignaturas
Set cupos_disponibles = cupos_disponibles - 1
Where asignatura_id = 2;

-- Materia 3 (Fracaso/Error)
Update Asignaturas
Set cupos_disponible = cupos_disponibles - 1
Where asignatura_id = 3;

Rollback;

Select asignatura_id, nombre_materia, cupos_disponibles
From Asignaturas
Where asignatura_id In (1,2);


--3 Control de bloqueos y niveles de aislamiento

Select * From Asignaturas
Where asignatura_id = 5;


-- Read Uncommitted
Set transaction isolation level read uncommitted;

Begin transaction;

Update Asignaturas
Set cupos_disponibles = 4
Where asignatura_id = 5;

Rollback;


-- Read committed
Set transaction isolation level read committed;

Begin Transaction;

Update Asignaturas
Set cupos_disponibles = 4
Where asignatura_id = 5;

Commit;


--Repeatable read
Update Asignaturas
Set cupos_disponibles = 3
Where asignatura_id = 5;


--Serializable
Insert into Asignaturas (nombre_materia , docente, cupos_disponibles)
Values
('Programacion', 'Msc. Gonzalez', 5);

Select * From Asignaturas;


--VISTA 1, Oferta académica

Create view Vista_OfertaAcademica
As select
	asignatura_id,
	nombre_materia,
	docente,
	cupos_disponibles
From Asignaturas
Where cupos_disponibles > 0;
Go

Select * From Vista_OfertaAcademica;

--VISTA 2, Detalle matrpicula

Create view Vista_DetalleMatricula
As select
	E.estudiante_id,
	E.nombre,
	E.facultad,
	A.nombre_materia,
	R.fecha_registro,
	R.estado
From Registros_Matricula R
Inner Join Estudiantes E
	On R.estudiante_id = E.estudiante_id
Inner Join Asignaturas A
	On R.asignatura_id = A.asignatura_id;
Go

Select * From Vista_DetalleMatricula;

--VISTA 3, Estudiantes saturados
Create view Vista_EstudiantesSaturados
As select
	E.estudiante_id,
	E.nombre,
	Count(*) as total_materias
From Estudiantes E
Inner Join Registros_Matricula R
	On E.estudiante_id = R.estudiante_id
Group by E.estudiante_id, E.nombre
Having Count(*) > 5;
Go

Select * From Vista_EstudiantesSaturados;

--Verificar cuántas materias tiene cada Estudiante

Select
	estudiante_id,
	Count(*) as total_materias
From Registros_Matricula
Group by estudiante_id;



--FUNCIONES

--FUNCIÓN 1

Create function fn_CalcularCostoMatricula 
(
	@id_estudiante Int
)
Returns decimal(10,2)
As begin
	Declare @totalMaterias Int;
	Declare @costo Decimal(10,2);

	Select @totalMaterias = Count(*)
	From Registros_Matricula
	Where estudiante_id = @id_estudiante;

	Set @costo = @totalMaterias * 25;

	Return @costo;

End;
Go

SELECT dbo.fn_CalcularCostoMatricula(2) AS costo;

--FUNCIóN 2

Create function fn_VerificarDisponibilidad
(
	@id_asignatura int
)
Returns Bit
As begin
	Declare @resultado Bit;

	If exists
	(
		Select *
		From Asignaturas
		Where asignatura_id = @id_asignatura
		And cupos_disponibles > 0
	)
		Set @resultado = 1;
	Else
		Set @resultado = 0;

	Return @resultado;
End;
Go

SELECT dbo.fn_VerificarDisponibilidad(2) AS disponible;


-- FUNCIÓN 3
Create function fn_ListaClase
(
	@id_asignatura Int
)
Returns Table
As Return
(
	Select
		E.nombre,
		E.cedula
	From Estudiantes E
	Inner Join Registros_Matricula R
		On E.estudiante_id = R.estudiante_id
	Where R.asignatura_id = @id_asignatura
);
Go

Select * From dbo.fn_ListaClase(1);


--PROCEDIMIENTOS ALMACENADOS


--PROCEDIMIENTO 1
Create Procedure sp_InscribirAsignatura
	@estudiante_id Int,
	@asignatura_id Int
As Begin

	Declare @cupos Int;

	Select @cupos = cupos_disponibles
	From Asignaturas
	Where asignatura_id = @asignatura_id;

	If @cupos > 0
	Begin
		Insert into Registros_Matricula
		(
			estudiante_id,
			asignatura_id,
			estado
		)
		Values
		(
			@estudiante_id,
			@asignatura_id,
			'confirmada'
		);
		Update Asignaturas
		Set cupos_disponibles = cupos_disponibles - 1
		Where asignatura_id = @asignatura_id;

		Print 'Matrícula realizada correctamente';
	End
	Else
	Begin
		Print 'No existen cupos disponibles'
	End
End;

--Ejemplo

Exec sp_InscribirAsignatura
	@estudiante_id = 1,
	@asignatura_id = 9;

Select * From Registros_Matricula
Where estudiante_id = 1;

Select * From Asignaturas
Where asignatura_id = 9;

--PROCEDIMIENTO 2

Create procedure sp_RetirarAsignatura
	@registro_id Int
As Begin

	Declare @asignatura_id Int;
	Select @asignatura_id = asignatura_id
	From Registros_Matricula
	Where registro_id = @registro_id;

	Update Asignaturas
	Set cupos_disponibles = cupos_disponibles + 1
	Where asignatura_id = @asignatura_id;

	Insert into Auditoria_Matriculas
	(
		registro_id,
		accion,
		usuario
	)
	Values
	(
		@registro_id,
		'Retiro',
		SYSTEM_USER
	);

	Delete From Registros_Matricula
	Where registro_id = @registro_id;
End;
Go

--Ejemplo
Select * From Registros_Matricula;

Exec sp_RetirarAsignatura 1111;

Select * From Auditoria_Matriculas;


--PROCEDIMIENTO 3

Create Procedure sp_ReporteCargaDocente
As Begin
	Select
		A.docente,
		Count(R.estudiante_id) as total_estudiantes
	From Asignaturas A
	Left Join Registros_Matricula R
		On A.asignatura_id = R.asignatura_id
	Group by A.docente
	Order by total_estudiantes Desc;
End;
Go

--Ejemplo

Exec sp_ReporteCargaDocente;


--TRIGGERS

--TRIGGER 1

Create trigger tr_AuditoriaMatricula_Insert
On Registros_Matricula
After Insert
As Begin
	Insert into Auditoria_Matriculas
	(
		registro_id,
		accion,
		usuario
	)
	Select
		registro_id,
		'Matriculación',
		SYSTEM_USER
	From inserted;  --Tabla temporal que contine los registros recién insertados
End;
Go

--Ejemplo

Insert into Registros_Matricula
(
	estudiante_id,
	asignatura_id,
	estado
)
Values
(
	3,
	2,
	'confirmada'
);

Select * From Auditoria_Matriculas;


--TRIGGER 2

Create Trigger tr_ValidarCupoNegativo
On Asignaturas
Instead of Update
As Begin

	If exists
	(
		Select * From inserted
		Where cupos_disponibles < 0
	)
	Begin
		Raiserror(
			'No se permiten cupos negativos',
			16,
			1
		);
		Return;
	End

	Update A
	Set A.nombre_materia = I.nombre_materia,
		A.docente = I.docente,
		A.cupos_disponibles = I.cupos_disponibles
	From Asignaturas A
	Inner Join inserted I
	On A.asignatura_id = I.asignatura_id;
End;
Go

--Ejemplo

Update Asignaturas
Set cupos_disponibles = -5
Where asignatura_id = 2;

Select * From Asignaturas
Where asignatura_id = 10; 

--TRIGGER 3

Create Trigger tr_LogCambioCupo
On Asignaturas
After Update
As Begin

	Insert into Historial_Cupos
	(
		asignatura_id,
		cupo_anterior,
		cupo_nuevo
	)
	Select
		D.asignatura_id,
		D.cupos_disponibles,
		I.cupos_disponibles
	From deleted D
	Inner Join inserted I
		On D.asignatura_id = I.asignatura_id
	Where D.cupos_disponibles <> I.cupos_disponibles;

End;
Go

--Ejemplo

Select * From Asignaturas
where asignatura_id = 2;

Update Asignaturas
Set cupos_disponibles = 20
Where asignatura_id = 2;

Select * From Historial_Cupos;