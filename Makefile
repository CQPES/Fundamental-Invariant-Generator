FC     = ifort
FFLAGS = -O3 -qopenmp -heap-arrays -warn -module mod
LIB    = -qmkl=parallel 

SRC    = $(wildcard src/*)
OBJ_MOD = obj/modules.m.o
OBJ_OTH = $(patsubst src/%.f90, obj/%.o, $(filter-out src/modules.f90, $(filter %.f90, $(SRC))))
EXE     = bin/invariants

$(EXE): $(OBJ_MOD) $(OBJ_OTH)
	@mkdir -p bin
	$(FC) $(FFLAGS) $+ $(LIB) -o $@

$(OBJ_OTH): $(OBJ_MOD)

obj/%.o : src/%.f90
	@mkdir -p obj mod
	$(FC) -c $< $(FFLAGS) -o $@

obj/%.m.o : src/%.f90
	@mkdir -p obj mod
	$(FC) -c $< $(FFLAGS) -o $@

clean:
	rm -rf obj mod bin
