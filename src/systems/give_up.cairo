#[system]
mod give_up_system {
    use array::ArrayTrait;
    use traits::Into;
    use dojo::world::Context;
    use starknet::ContractAddress;
    use four_connect_dojo::components::{Position, Piece, PieceColor, Game, GameTurn, PlayersId};

    fn execute(ctx: Context, game_id: felt252, caller: ContractAddress) {
        let current_game = get !(ctx.world, game_id.into(), (Game));
        let player_id = get !(ctx.world, game_id.into(), (PlayersId));

        if caller == player_id.white {
            set !(
                ctx.world,
                game_id.into(),
                (Game { status: false, winner: Option::Some(PieceColor::Black(())) })
            );
        } else if (caller == player_id.black) {
            set !(
                ctx.world,
                game_id.into(),
                (Game { status: false, winner: Option::Some(PieceColor::White(())) })
            );
        };
    }
}
