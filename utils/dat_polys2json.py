import argparse
import gzip
import json
import re
from typing import List


def _parse_args():
    parser = argparse.ArgumentParser(
        description="Convert FI dat.polys to JaxPIP .json",
    )

    parser.add_argument(
        "dat_polys",
        help="Path to input dat.polys file",
    )

    parser.add_argument(
        "json_file",
        help="Path to output json file, recommend 'FI_AxByCz.json.gz'",
    )

    parser.add_argument(
        "-n",
        "--num_atoms",
        type=int,
        required=True,
        help="Number of atoms",
    )

    parser.add_argument(
        "--gz",
        action="store_true",
        help="Compress with gzip",
    )

    return parser.parse_args()


def parse_dat_polys(
    filepath: str,
    nr: int,
) -> List[List[List[int]]]:
    # match 'r10^2' or 'r3'
    pattern = re.compile(r"r(\d+)(?:\^(\d+))?")

    basis_list = []

    # keep compatibility with MSA
    basis_list.append([[0] * nr])

    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()

            if not line:
                continue

            _, rhs = line.split("=")

            monomials_str = rhs.split("+")

            fi_terms = []

            for mono_str in monomials_str:
                exp_vec = [0] * nr

                for match in pattern.finditer(mono_str):
                    # Fortran(1-based) -> Python(0-based)
                    idx = int(match.group(1)) - 1
                    power = int(match.group(2)) if match.group(2) else 1
                    exp_vec[idx] = power

                fi_terms.append(exp_vec)

            basis_list.append(fi_terms)

    return basis_list


if __name__ == "__main__":
    args = _parse_args()

    num_dist = int(args.num_atoms * (args.num_atoms - 1) / 2)

    basis_set = parse_dat_polys(args.dat_polys, num_dist)

    if args.gz and (not args.json_file.endswith(".json.gz")):
        args.json_file += ".gz"

    if args.json_file.endswith(".gz"):
        with gzip.open(args.json_file, "wt", encoding="utf-8") as f:
            json.dump(basis_set, f)
    else:
        with open(args.json_file, "w", encoding="utf-8") as f:
            json.dump(basis_set, f)
